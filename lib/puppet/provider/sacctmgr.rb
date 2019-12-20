class Puppet::Provider::Sacctmgr < Puppet::Provider

  initvars
  commands :sacctmgr_cmd => 'sacctmgr'

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

  def self.type_properties
    resource_type.validproperties.reject { |p| p == :ensure }.sort
  end
  def type_properties
    self.class.type_properties
  end

  def self.type_params
    resource_type.parameters.reject { |p| [:name,:provider].include?(p) }.sort
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
    sacctmgr_properties.map { |r| r.to_s.gsub("_", "") }.join(",")
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

  def self.sacctmgr(args)
    if sacctmgr_path.nil?
      sacctmgr_path = which('sacctmgr')
    end
    raise Puppet::Error, "Unable to find sacctmgr executable" if sacctmgr_path.nil?
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
    args = args + [ "--noheader", "--parsable2" ]
    sacctmgr(args)
  end

  def self.set_value_or_default(value, default)
    return default if value.nil?
    return default if value.empty?
    return value
  end

  def self.get_names
    sacctmgr([sacctmgr_show, "format=#{sacctmgr_name_attribute}"].flatten).split("\n")
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
      if raw_value.include?(',')
        value = raw_value.split(',')
      elsif raw_value == ''
        value = :absent
      else
        value = Array(raw_value)
      end
    elsif raw_value == ''
      value = :absent
    elsif raw_value.include?('=')
      value = {}
      raw_value.split(',').each do |i|
        k, v = i.split('=')
        value[k] = v
      end
    elsif raw_value.include?(',')
      value = raw_value.split(',')
    else
      value = raw_value
    end
    value
  end

  def set_values(create)
    result = []
    if create
      properties = type_properties + type_params
    else
      properties = @property_flush.keys
    end
    properties.each do |property|
      if create
        value = resource[property]
      else
        value = @property_flush[property]
      end
      next if ((value == :absent || value == [:absent]) && create)
      next if value.nil?
      name = property.to_s.gsub('_', '')
      if !create && (value == :absent || value == [:absent])
        value = set_absent_values[property] || '-1'
      elsif value.is_a?(Array)
        value = value.join(',')
      elsif value.is_a?(Hash)
        value = value.map {|k,v| "#{k}=#{v}" }.join(',')
      elsif value.is_a?(String)
        if value.match(/\s/)
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
