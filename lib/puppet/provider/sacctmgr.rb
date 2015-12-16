class Puppet::Provider::Sacctmgr < Puppet::Provider

  initvars
  commands :sacctmgr => 'sacctmgr'

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

  def self.valid_properties
    resource_type.validproperties.reject { |p| p == :ensure || p.to_s =~ /_tres_/ }.sort
  end

  def self.all_properties
    [name_attribute, valid_properties].flatten
  end

  def self.sacctmgr_properties
    [sacctmgr_name_attribute, valid_properties].flatten
  end
  
  def self.format_fields
    sacctmgr_properties.map { |r| r.to_s.gsub("_", "") }.join(",")
  end

  def self.sacctmgr_show
    show_args = [ "--noheader", "--parsable2", "show" ]
    case resource_type.to_s
    when 'Puppet::Type::Slurm_cluster'
      show_args << 'cluster'
    when 'Puppet::Type::Slurm_qos'
      show_args << 'qos'
    end

    show_args
  end

  def self.set_value_or_default(value, default)
    return default if value.nil?
    return default if value.empty?
    return value
  end

  def self.get_names
    sacctmgr([sacctmgr_show, "format=#{sacctmgr_name_attribute}"].flatten).split("\n")
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def set_values
    result = []
    self.class.valid_properties.each do |property|
      next if @resource[property].nil?
      name = property.to_s.gsub('_', '')
      case @resource[property]
      when Array
        value = @resource[property].join(",")
      when String
        if @resource[property].match(/\s/)
          value = "'#{@resource[property]}'"
        else
          value = @resource[property]
        end
      else
        value = @resource[property]
      end

      result << "#{name}=#{value}"
    end

    result
  end

end
