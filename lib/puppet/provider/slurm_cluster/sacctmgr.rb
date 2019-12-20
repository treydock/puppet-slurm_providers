require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurm_cluster).provide(:sacctmgr, :parent => Puppet::Provider::Sacctmgr) do
  desc "SLURM cluster type provider"

  mk_resource_methods

  def set_absent_values
    {
      features: "''",
      federation: "''",
      flags: 'None',
    }
  end

  def self.absent_values
    {
      features: 'None',
      federation: 'NA',
    }
  end

  def self.array_properties
    [:flags,:features]
  end

  def self.instances
    clusters = []
    sacctmgr_list.each_line do |line|
      Puppet.debug("slurm_cluster instances: LINE=#{line}")
      values = line.chomp.split('|')
      cluster = {}
      cluster[:ensure] = :present
      all_properties.each_with_index do |property, index|
        if property == :name
          cluster[:name] = values[index]
          next
        end
        raw_value = values[index]
        Puppet.debug("slurm_cluster instances: property=#{property} index=#{index} raw_value=#{raw_value}")
        value = parse_value(property, raw_value.to_s)
        Puppet.debug("slurm_cluster instances: value=#{value} class=#{value.class}")
        cluster[property] = value
      end
      clusters << new(cluster)
    end
    clusters
  end

  def self.prefetch(resources)
    clusters = instances
    resources.keys.each do |name|
      provider = clusters.find { |c| c.name == name }
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
