# scontrol provider parent class
class Puppet::Provider::Scontrol < Puppet::Provider
  initvars
  commands scontrol_cmd: 'scontrol'

  class << self
    attr_accessor :install_prefix
  end

  def self.scontrol(args)
    scontrol_path = nil
    unless @install_prefix.nil?
      scontrol_path = File.join(@install_prefix, 'bin', 'scontrol')
    end
    if scontrol_path.nil?
      scontrol_path = which('scontrol')
      Puppet.debug("Used which to find scontrol: path=#{scontrol_path}")
    end
    if scontrol_path.nil?
      [
        '/bin',
        '/usr/bin',
        '/usr/local/bin',
      ].each do |dir|
        path = File.join(dir, 'scontrol')
        next unless File.exist?(path)
        scontrol_path = path
        Puppet.debug("Used static search to find scontrol: path=#{scontrol_path}")
        break
      end
    end
    raise Puppet::Error, 'Unable to find scontrol executable' if scontrol_path.nil?
    cmd = [scontrol_path] + args
    execute(cmd)
  end

  def scontrol(*args)
    self.class.scontrol(*args)
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

  def set_properties
    [type_params, type_properties].flatten
  end

  def self.hash_colon_properties
    []
  end

  def hash_colon_properties
    self.class.hash_colon_properties
  end

  def self.scontrol_resource
    case resource_type.to_s
    when 'Puppet::Type::Slurm_reservation'
      'reservation'
    end
  end

  def scontrol_resource
    self.class.scontrol_resource
  end

  def self.scontrol_name_key
    case resource_type.to_s
    when 'Puppet::Type::Slurm_reservation'
      'Reservation'
    end
  end

  def scontrol_name_key
    self.class.scontrol_resource
  end

  def self.convert_scontrol_key(key)
    if key =~ %r{^[A-Z]+$}
      return key.downcase
    end
    key.gsub(%r{([a-z])([A-Z])}, '\1_\2').downcase
  end

  def self.scontrol_list
    args = ['show']
    args << scontrol_resource
    args << '--oneliner'
    scontrol(args)
  rescue Puppet::Error => e
    Puppet.info("Unable to show #{scontrol_resource} resources: #{e}")
    return ''
  end

  def self.parse_value(property, raw_value)
    Puppet.debug("parse_value: property=#{property} raw_value(#{raw_value.class})=#{raw_value}")
    if absent_values.key?(property)
      Puppet.debug("parse_value: absent_values found: #{(raw_value == absent_values[property])}")
      if raw_value == absent_values[property]
        return :absent
      end
    end
    if raw_value == '(null)'
      return :absent
    end
    if array_properties.include?(property)
      value = if raw_value.include?(',')
                raw_value.split(',')
              elsif raw_value == ''
                :absent
              else
                Array(raw_value)
              end
    elsif hash_colon_properties.include?(property)
      value = {}
      values = raw_value.split(',')
      values.each do |rv|
        kvs = rv.split(':')
        value[kvs[0]] = if kvs.size == 1
                          '1'
                        else
                          kvs[1]
                        end
      end
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

  def set_values(create) # rubocop:disable Style/AccessorMethodName
    result = []
    properties = if create
                   set_properties
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
        value = set_absent_values[property] || ''
      elsif hash_colon_properties.include?(property)
        value = value.map { |k, _v| "#{k}:#{value}" }.join(',')
      elsif value.is_a?(Array)
        value = value.join(',')
      elsif value.is_a?(Hash)
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
    scontrol(['create', scontrol_resource, "#{scontrol_name_key}=#{@resource[:name]}", set_values(true)].flatten)
    @property_hash[:ensure] = :present
  end

  def flush
    unless @property_flush.empty?
      scontrol(['update', "#{scontrol_name_key}=#{@resource[:name]}", set_values(false)].flatten)
    end
    @property_hash = resource.to_hash
  end

  def destroy
    scontrol(['delete', "#{scontrol_name_key}=#{@resource[:name]}"].flatten)
    @property_hash.clear
  end
end
