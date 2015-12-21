$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/sacctmgr'
require 'puppet/util/slurm'

Puppet::Type.type(:slurm_qos).provide(:sacctmgr_tres, :parent => Puppet::Provider::Sacctmgr) do
  extend Puppet::Util::Slurm

  @docs =<<-EOS
    SLURM QOS type provider
  EOS

  has_feature :slurm_with_tres
  defaultfor :slurm_version => /^15/
  confine :true => /^15/.match(Facter.value(:slurm_version))

  mk_resource_methods

  def self.generic_fields
    [
      :name, :description, :flags,
      :grp_jobs, :grp_submit_jobs, :max_jobs, :max_submit_jobs, :max_wall,
      :preempt, :preempt_mode, :priority, :usage_factor
    ]
  end

  def self.tres_fields
    [
      :grp_tres_mins, :grp_tres_run_mins, :grp_tres, :max_tres_mins,
      :max_tres_per_job, :max_tres_per_node, :max_tres_per_user, :min_tres_per_job,
    ]
  end

  def self.fields
    generic_fields + tres_fields
  end

  def self.properties
    generic_fields + tres_fields
  end

  def self.format_fields
    fields.map { |r| r.to_s.gsub("_", "") }.join(",")
  end

  def self.get_qos_properties(name)
    qos_properties = {}
    qos = sacctmgr([sacctmgr_show, "name=#{name}", "format=#{format_fields}"].flatten)
    values = qos.chomp.split("|")

    qos_properties[:provider] = :sacctmgr_tres
    qos_properties[:ensure] = :present

    fields.each_with_index do |property,index|
      value = values[index] || ''
      case property
      when :description
        qos_properties[property] = value.empty? ? qos_properties[:name] : value
      when :flags
        qos_properties[property] = value.empty? ? ["-1"] : value.split(",").sort
      when :priority
        qos_properties[property] = value.empty? ? "0" : value
      when :preempt
        if value.empty?
          qos_properties[property] = ["''"]
        else
          qos_properties[property] = value.split(",").sort
        end
      when :preempt_mode
        qos_properties[property] = value.empty? ? "cluster" : value
      when :usage_factor
        qos_properties[property] = value.empty? ? "1.000000" : value
      when :grp_tres_mins, :grp_tres_run_mins, :grp_tres, :max_tres_mins, :max_tres_per_job, :max_tres_per_node, :max_tres_per_user
        qos_properties[property] = format_tres_values(value)
      when :min_tres_per_job
        qos_properties[property] = format_tres_values(value, '1')
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

  def set_values
    result = []
    tres_values = {}
    self.class.properties.each do |property|
      next if property == :name
      next if @resource[property].nil?

      name = property.to_s.gsub('_', '')
      case @resource[property]
      when Array
        value = @resource[property].join(",")
        #if value.empty?
        #  value = "''"
        #end
      when String
        if @resource[property].match(/\s/)
          value = "'#{@resource[property]}'"
        elsif @resource[property].empty?
          value = "''"
        else
          value = @resource[property]
        end
      else
        value = @resource[property]
      end

      result << "#{name}=#{value}"
    end

    tres_values.each_pair do |key, value|
      result << "#{key}=#{value.join(',')}"
    end

    result
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
