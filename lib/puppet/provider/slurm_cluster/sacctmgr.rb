require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurm_cluster).provide(:sacctmgr, :parent => Puppet::Provider::Sacctmgr) do
  @docs =<<-EOS
    SLURM cluster type provider
  EOS

  mk_resource_methods

  def self.get_cluster_properties(name)
    cluster_properties = {}
    cluster = sacctmgr([sacctmgr_show, "cluster=#{name}", "format=#{format_fields}"].flatten)
    values = cluster.chomp.split("|")

    cluster_properties[:provider] = :sacctmgr
    cluster_properties[:ensure] = :present

    all_properties.each_with_index do |property,index|
      raw_value = values[index]
      next if raw_value.nil?
      value = values[index]
      cluster_properties[property] = value
    end

    Puppet.debug("Slurm_cluster properties: #{cluster_properties.inspect}")
    cluster_properties
  end

  def self.instances
    get_names.collect do |name|
      cluster_properties = get_cluster_properties(name)
      new(cluster_properties)
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def create_cluster
    sacctmgr(['-i', 'create', 'cluster', @resource[:name]].flatten)
  end

  def modify_cluster
    sacctmgr(['-i', 'modify', 'cluster', @resource[:name], 'set', set_values].flatten)
  end

  def destroy_cluster
    sacctmgr(['-i', 'delete', 'cluster', "name=#{@resource[:name]}"].flatten)
  end

  def set_cluster
    case @property_hash[:ensure]
    when :absent
      destroy_cluster
    when :present
      if @property_hash[:name].nil?
        create_cluster
      else
        modify_cluster
      end
    end
  end

  def flush
    set_cluster

    @property_hash = self.class.get_cluster_properties(@resource[:name])
  end
end
