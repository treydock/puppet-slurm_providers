require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurm_qos).provide(:sacctmgr, :parent => Puppet::Provider::Sacctmgr) do
  @docs =<<-EOS
    SLURM QOS type provider
  EOS

  mk_resource_methods

  def self.get_qos_properties(name)
    qos_properties = {}
    qos = sacctmgr([sacctmgr_show, "name=#{name}", "format=#{format_fields}"].flatten)
    values = qos.chomp.split("|")

    qos_properties[:provider] = :sacctmgr
    qos_properties[:ensure] = :present

    all_properties.each_with_index do |property,index|
      value = values[index] || ''
      case property
      when :description
        qos_properties[property] = value.empty? ? qos_properties[:name] : value
      when :flags
        qos_properties[property] = value.empty? ? ["-1"] : value.split(",").sort
      when :priority
        qos_properties[property] = value.empty? ? "0" : value
      when :preempt
        if ! value.empty?
          qos_properties[property] = value.split(",").sort
        end
      when :preempt_mode
        qos_properties[property] = value.empty? ? "cluster" : value
      when :usage_factor
        qos_properties[property] = value.empty? ? "1.000000" : value
      else
        qos_properties[property] = value.empty? ? "-1" : value
      end
    end

    Puppet.debug("Slurm_qos properties: #{qos_properties.inspect}")
    qos_properties
  end

  def self.instances
    get_names.collect do |name|
      qos_properties = get_qos_properties(name)
      new(qos_properties)
    end
  end

  def max_wall
    value = @property_hash[:max_wall]
    return '-1' if value == '-1'

    match = value.match(/^(?:([0-9]+)-)?([0-9]{2}):([0-9]{2}):([0-9]{2})$/)
    if match
      str, days, hours, minutes, seconds = match.to_a
      if days
        hours = hours.to_i + (24 * days.to_i)
      end

      return "#{hours}:#{minutes}:#{seconds}"
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def create_qos
    sacctmgr(['-i', 'create', 'qos', @resource[:name], set_values].flatten)
  end

  def modify_qos
    sacctmgr(['-i', 'modify', 'qos', @resource[:name], 'set', set_values].flatten)
  end

  def destroy_qos
    sacctmgr(['-i', 'delete', 'qos', "name=#{@resource[:name]}"].flatten)
  end

  def set_qos
    case @property_hash[:ensure]
    when :absent
      destroy_qos
    when :present
      if @property_hash[:name].nil?
        create_qos
      else
        modify_qos
      end
    end
  end

  def flush
    set_qos

    @property_hash = self.class.get_qos_properties(@resource[:name])
  end
end
