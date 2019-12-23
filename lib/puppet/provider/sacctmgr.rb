# sacctmgr provider parent class
class Puppet::Provider::Sacctmgr < Puppet::Provider
  initvars
  commands sacctmgr_cmd: 'sacctmgr'

  class << self
    attr_accessor :sacctmgr_path
  end

  def self.name_attribute
    :name
  end

  def self.sacctmgr_name_attribute
    case resource_type.to_s
    when 'Puppet::Type::Slurm_cluster'
      :cluster
    else
      :name
    end
  end

  def self.time_to_seconds
    []
  end

  def time_to_seconds
    self.class.time_to_seconds
  end

  def self.type_properties
    resource_type.validproperties.reject { |p| p == :ensure }.sort
  end

  def type_properties
    self.class.type_properties
  end

  def self.type_params
    resource_type.parameters.reject { |p| [:name, :provider].include?(p) }.sort
  end

  def type_params
    self.class.type_params
  end

  def self.all_properties
    [name_attribute, type_properties].flatten
  end

  def self.sacctmgr_properties
    [sacctmgr_name_attribute, type_params, type_properties].flatten
  end

  def self.format_fields
    sacctmgr_properties.map { |r| r.to_s.delete('_') }.join(',')
  end

  def self.sacctmgr_resource
    case resource_type.to_s
    when 'Puppet::Type::Slurm_cluster'
      'cluster'
    when 'Puppet::Type::Slurm_qos'
      'qos'
    end
  end

  def sacctmgr_resource
    self.class.sacctmgr_resource
  end

  def self.tres
    values = []
    args = ['show', 'tres', 'format=type,name,id', '--noheader', '--parsable2']
    output = sacctmgr(args)
    output.each_line do |line|
      data = line.chomp.split('|')
      value = if data[1] != ''
                "#{data[0]}/#{data[1]}"
              else
                data[0]
              end
      values << value
    end
    values
  end

  def self.sacctmgr(args)
    if sacctmgr_path.nil?
      sacctmgr_path = which('sacctmgr')
    end
    raise Puppet::Error, 'Unable to find sacctmgr executable' if sacctmgr_path.nil?
    cmd = [sacctmgr_path] + args
    execute(cmd)
  end

  def sacctmgr(*args)
    self.class.sacctmgr(*args)
  end

  def self.sacctmgr_list
    args = ['list']
    args << sacctmgr_resource
    args << "format=#{format_fields}"
    args += ['--noheader', '--parsable2']
    sacctmgr(args)
  end

  def self.parse_time(t)
    time = PuppetX::SLURM::Util.parse_time(t)
    return t if time.nil?
    time[3] + (time[2] * 60) + (time[1] * 3600) + (time[0] * 86_400)
  end

  def self.parse_value(property, raw_value)
    Puppet.debug("parse_value: property=#{property} raw_value(#{raw_value.class})=#{raw_value}")
    if absent_values.key?(property)
      Puppet.debug("parse_value: absent_values found: #{(raw_value == absent_values[property])}")
      if raw_value == absent_values[property]
        return :absent
      end
    end
    if array_properties.include?(property)
      value = if raw_value.include?(',')
                raw_value.split(',')
              elsif raw_value == ''
                :absent
              else
                Array(raw_value)
              end
    elsif time_to_seconds.include?(property)
      value = parse_time(raw_value).to_s
    elsif raw_value == ''
      value = :absent
    elsif raw_value.include?('=')
      value = {}
      raw_value.split(',').each do |i|
        k, v = i.split('=')
        if v.to_s[-1] == 'M'
          v.chop!
        end
        value[k] = v.to_s
      end
    elsif raw_value.include?(',')
      value = raw_value.split(',')
    else
      value = raw_value
    end
    value
  end

  def parse_tres(value)
    tres = {}
    value.split(',').each do |val|
      k, v = val.split('=')
      tres[k] = v
    end
    tres
  end

  def set_values(create) # rubocop:disable Style/AccessorMethodName
    result = []
    properties = if create
                   type_properties + type_params
                 else
                   @property_flush.keys
                 end
    properties.each do |property|
      value = if create
                resource[property]
              else
                @property_flush[property]
              end
      next if (value == :absent || value == [:absent]) && create
      next if value.nil?
      name = property.to_s.delete('_')
      if !create && (value == :absent || value == [:absent])
        if property.to_s.include?('tres')
          current_value = @property_hash[property]
          next if current_value.nil?
          next if current_value == :absent
          new_tres = {}
          current_value.each_pair do |k, _v|
            new_tres[k] = '-1'
          end
          value = new_tres.map { |k, v| "#{k}=#{v}" }.join(',')
        else
          value = set_absent_values[property] || '-1'
        end
      elsif value.is_a?(Array)
        value = value.join(',')
      elsif value.is_a?(Hash)
        current_value = @property_hash[property] || {}
        current_value = {} if current_value == :absent
        current_value.each_pair do |k, _v|
          unless value.key?(k)
            value[k] = '-1'
          end
        end
        value = value.map { |k, v| "#{k}=#{v}" }.join(',')
      elsif value.is_a?(String)
        if value =~ %r{\s}
          value = "'#{value}'"
        end
      end
      result << "#{name}=#{value}"
    end

    result
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    sacctmgr(['-i', 'create', sacctmgr_resource, @resource[:name], set_values(true)].flatten)
    @property_hash[:ensure] = :present
  end

  def flush
    unless @property_flush.empty?
      sacctmgr(['-i', 'modify', sacctmgr_resource, @resource[:name], 'set', set_values(false)].flatten)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    sacctmgr(['-i', 'delete', sacctmgr_resource, @resource[:name]].flatten)
    @property_hash.clear
  end
end
