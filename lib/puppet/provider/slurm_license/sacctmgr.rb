# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurm_license).provide(:sacctmgr, parent: Puppet::Provider::Sacctmgr) do
  desc 'SLURM license resource type provider'

  mk_resource_methods

  def self.name_attribute
    :resource_name
  end

  def set_absent_values
    {
      description: "''",
      server_type: '',
    }
  end

  def self.absent_values
    {}
  end

  def self.array_properties
    []
  end

  def self.fields_name_overrides
    {
      percent_allowed: :allowed,
    }
  end

  def self.instances
    licenses = []
    sacctmgr_list(false, {}, ['withclusters']).each_line do |line|
      Puppet.debug("slurm_license instances: LINE=#{line}")
      values = line.chomp.split('|')
      license = {}
      license[:ensure] = :present
      all_properties.each_with_index do |property, index|
        next if [:count, :server_type].include?(property)

        if property == :name
          license[:resource_name] = values[index]
        end
        raw_value = values[index]
        Puppet.debug("slurm_license instances: property=#{property} index=#{index} raw_value=#{raw_value}")
        value = parse_value(property, raw_value.to_s)
        Puppet.debug("slurm_license instances: value=#{value} class=#{value.class}")
        license[property] = value
      end
      license[:name] = "#{license[:resource_name]}@#{license[:server]} for #{license[:cluster]}"
      licenses << new(license)
    end
    sacctmgr_list.each_line do |line|
      Puppet.debug("slurm_license instances: LINE=#{line}")
      values = line.chomp.split('|')
      license = {}
      license[:ensure] = :present
      all_properties.each_with_index do |property, index|
        next if [:percent_allowed, :cluster].include?(property)

        if property == :name
          license[:resource_name] = values[index]
        end
        raw_value = values[index]
        Puppet.debug("slurm_license instances: property=#{property} index=#{index} raw_value=#{raw_value}")
        value = parse_value(property, raw_value.to_s)
        Puppet.debug("slurm_license instances: value=#{value} class=#{value.class}")
        license[property] = value
      end
      license[:name] = "#{license[:resource_name]}@#{license[:server]}"
      licenses << new(license)
    end
    licenses
  end

  def self.prefetch(resources)
    licenses = instances
    resources.each_key do |name|
      provider = licenses.find do |c|
        if c.cluster.to_s == 'absent'
          c.resource_name == resources[name][:resource_name] && c.server == resources[name][:server] && resources[name][:cluster].nil?
        else
          c.resource_name == resources[name][:resource_name] && c.server == resources[name][:server] && c.cluster == resources[name][:cluster]
        end
      end
      if provider
        resources[name].provider = provider
      end
    end
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  type_properties.each do |prop|
    define_method "#{prop}=".to_sym do |value|
      @property_flush[prop] = value
    end
  end
end
