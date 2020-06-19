require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurm_account).provide(:sacctmgr, parent: Puppet::Provider::Sacctmgr) do
  desc 'SLURM account type provider'

  mk_resource_methods

  def self.name_attribute
    :account
  end

  def set_absent_values
    {
      description: "''",
      qos_level: "''",
    }
  end

  def self.absent_values
    {
    }
  end

  def self.array_properties
    [:qos_level]
  end

  def property_name_overrides
    {
      parent_name: :parent,
    }
  end

  def self.instances
    accounts = []
    sacctmgr_list(true, 'user' => '').each_line do |line|
      Puppet.debug("slurm_account instances: LINE=#{line}")
      values = line.chomp.split('|')
      account = {}
      account[:ensure] = :present
      all_properties.each_with_index do |property, index|
        if property == :name
          account[:account] = values[index]
        end
        raw_value = values[index]
        Puppet.debug("slurm_account instances: property=#{property} index=#{index} raw_value=#{raw_value}")
        value = parse_value(property, raw_value.to_s)
        Puppet.debug("slurm_account instances: value=#{value} class=#{value.class}")
        account[property] = value
      end
      account[:name] = "#{account[:account]} on #{account[:cluster]}"
      accounts << new(account)
    end
    accounts
  end

  def self.prefetch(resources)
    accounts = instances
    resources.keys.each do |name|
      provider = accounts.find { |c| c.account == resources[name][:account] && c.cluster == resources[name][:cluster] }
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
