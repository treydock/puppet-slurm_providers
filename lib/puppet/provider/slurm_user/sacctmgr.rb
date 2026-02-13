# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurm_user).provide(:sacctmgr, parent: Puppet::Provider::Sacctmgr) do
  desc 'SLURM user type provider'

  mk_resource_methods

  def self.name_attribute
    :user
  end

  def set_absent_values
    {
      qos: "''",
    }
  end

  def self.absent_values
    {}
  end

  def self.array_properties
    [:qos]
  end

  def property_skip_set_values
    [:admin_level]
  end

  def self.instances
    users = []
    sacctmgr_list(true).each_line do |line|
      Puppet.debug("slurm_user instances: LINE=#{line}")
      values = line.chomp.split('|')
      user = {}
      user[:ensure] = :present
      all_properties.each_with_index do |property, index|
        if property == :name
          user[:user] = values[index]
        end
        # Skip accounts where user is empty string
        next if user[:user] == ''

        raw_value = values[index]
        Puppet.debug("slurm_user instances: property=#{property} index=#{index} raw_value=#{raw_value}")
        value = parse_value(property, raw_value.to_s)
        Puppet.debug("slurm_user instances: value=#{value} class=#{value.class}")
        user[property] = value
      end
      user[:name] = if user[:partition] != :absent
                      "#{user[:user]} under #{user[:account]} on #{user[:cluster]} partition #{user[:partition]}"
                    else
                      "#{user[:user]} under #{user[:account]} on #{user[:cluster]}"
                    end
      users << new(user)
    end
    users
  end

  def self.prefetch(resources)
    users = instances
    resources.each_key do |name|
      provider = users.find do |c|
        c.user == resources[name][:user] &&
          c.account == resources[name][:account] && c.cluster == resources[name][:cluster] && c.partition == resources[name][:partition]
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

  def set_admin_level
    value = @property_flush[:admin_level]
    return if value.nil?

    Puppet.notice("Setting SLURM adminlevel=#{value} for user=#{resource[:user]}")
    cmd = ['-i', 'modify', 'user', 'where', "user=#{resource[:user]}", 'set', "adminlevel=#{value}"]
    sacctmgr(cmd)
  end

  def destroy
    if (@resource[:user] == 'root') && (@resource[:partition] == :absent)
      Puppet.warning("Slurm_user[#{@resource[:name]}] Not permitted to delete root user. Must define root user or remove cluster")
      return
    end
    super
  end
end
