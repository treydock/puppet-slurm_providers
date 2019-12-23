require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurm_qos).provide(:sacctmgr, parent: Puppet::Provider::Sacctmgr) do
  desc 'SLURM qos type provider'

  mk_resource_methods

  def set_absent_values
    {
      description: "''",
      flags: '-1',
    }
  end

  def self.absent_values
    {
    }
  end

  def self.array_properties
    [:flags, :preempt]
  end

  def self.time_to_seconds
    [:grace_time]
  end

  def time_to_seconds
    self.class.time_to_seconds
  end

  def self.instances
    qoses = []
    sacctmgr_list.each_line do |line|
      Puppet.debug("slurm_qos instances: LINE=#{line}")
      values = line.chomp.split('|')
      qos = {}
      qos[:ensure] = :present
      all_properties.each_with_index do |property, index|
        if property == :name
          qos[:name] = values[index]
          next
        end
        raw_value = values[index]
        Puppet.debug("slurm_qos instances: property=#{property} index=#{index} raw_value=#{raw_value}")
        value = parse_value(property, raw_value.to_s)
        Puppet.debug("slurm_qos instances: value=#{value} class=#{value.class}")
        qos[property] = value
      end
      qoses << new(qos)
    end
    qoses
  end

  def self.prefetch(resources)
    qoses = instances
    resources.keys.each do |name|
      provider = qoses.find { |c| c.name == name }
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
