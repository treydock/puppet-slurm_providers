# sacctmgr provider parent class
class Puppet::Provider::Sacctmgr < Puppet::Provider
  initvars
  commands sacctmgr_cmd: 'sacctmgr'

  class << self
    attr_accessor :install_prefix
  end

  def self.name_attribute
    :name
  end

  def self.sacctmgr_name_attribute
    case resource_type.to_s
    when 'Puppet::Type::Slurm_cluster'
      :cluster
    when 'Puppet::Type::Slurm_account'
      :account
    when 'Puppet::Type::Slurm_user'
      :user
    else
      :name
    end
  end

  def self.time_to_seconds
    []
  end

  def time_to_seconds
    self.class.time_to_seconds
  end

  def self.type_properties
    resource_type.validproperties.reject { |p| p == :ensure }.sort
  end

  def type_properties
    self.class.type_properties
  end

  def self.type_params
    resource_type.parameters.reject { |p| [:name, :resource_name, :provider].include?(p) }.sort
  end

  def type_params
    self.class.type_params
  end

  def self.all_properties
    [name_attribute, (type_params - [sacctmgr_name_attribute]), type_properties].flatten
  end

  def self.sacctmgr_properties
    values = [sacctmgr_name_attribute, (type_params - [sacctmgr_name_attribute]), type_properties].flatten
    properties = []
    values.each do |v|
      properties << if fields_name_overrides.key?(v)
                      fields_name_overrides[v]
                    else
                      v
                    end
    end
    properties
  end

  def self.format_fields
    sacctmgr_properties.map { |r| r.to_s.delete('_') }.join(',')
  end

  def property_name_overrides
    {}
  end

  def self.fields_name_overrides
    {}
  end

  def property_skip_set_values
    []
  end

  def self.sacctmgr_resource
    case resource_type.to_s
    when 'Puppet::Type::Slurm_cluster'
      'cluster'
    when 'Puppet::Type::Slurm_qos'
      'qos'
    when 'Puppet::Type::Slurm_account'
      'account'
    when 'Puppet::Type::Slurm_user'
      'user'
    when 'Puppet::Type::Slurm_license'
      'resource'
    end
  end

  def sacctmgr_resource
    self.class.sacctmgr_resource
  end

  def self.tres
    values = []
    args = ['show', 'tres', 'format=type,name,id', '--noheader', '--parsable2']
    output = sacctmgr(args)
    output.each_line do |line|
      data = line.chomp.split('|')
      value = if data[1] != ''
                "#{data[0]}/#{data[1]}"
              else
                data[0]
              end
      values << value
    end
    values
  end

  def self.sacctmgr(args, options = {})
    sacctmgr_path = nil
    unless @install_prefix.nil?
      sacctmgr_path = File.join(@install_prefix, 'bin', 'sacctmgr')
    end
    if sacctmgr_path.nil?
      sacctmgr_path = which('sacctmgr')
      Puppet.debug("Used which to find sacctmgr: path=#{sacctmgr_path}")
    end
    if sacctmgr_path.nil?
      [
        '/bin',
        '/usr/bin',
        '/usr/local/bin',
      ].each do |dir|
        path = File.join(dir, 'sacctmgr')
        next unless File.exist?(path)
        sacctmgr_path = path
        Puppet.debug("Used static search to find sacctmgr: path=#{sacctmgr_path}")
        break
      end
    end
    raise Puppet::Error, 'Unable to find sacctmgr executable' if sacctmgr_path.nil?
    cmd = [sacctmgr_path] + args
    default_options = { failonfail: true, combine: true }
    ret = execute(cmd, default_options.merge(options))
    return ret
  rescue Puppet::Error => e
    Puppet.err("Failed to run sacctmgr command: #{e}")
    raise
  end

  def sacctmgr(*args)
    self.class.sacctmgr(*args)
  end

  def self.sacctmgr_list(withassoc = false, filter = {}, flags = [])
    args = ['list']
    args << sacctmgr_resource
    args << "format=#{format_fields}"
    args += ['--noheader', '--parsable2']
    if withassoc
      args << 'withassoc'
    end
    unless filter.empty?
      args << 'where'
    end
    filter.each do |k, v|
      args << "#{k}=#{v}"
    end
    flags.each do |f|
      args << f
    end
    sacctmgr(args)
  rescue Puppet::Error => e
    Puppet.err("Unable to list #{sacctmgr_resource} resources: #{e}")
    return ''
  end

  def self.sacctmgr_list_assoc(format = [], filter = {})
    args = ['list']
    args << sacctmgr_resource
    args << "format=#{format.join(',')}"
    args += ['--noheader', '--parsable2']
    args << 'withassoc'
    unless filter.empty?
      args << 'where'
    end
    filter.each do |k, v|
      args << "#{k}=#{v}"
    end
    sacctmgr(args)
  rescue Puppet::Error => e
    Puppet.err("Unable to list assoc #{sacctmgr_resource} resources: #{e}")
    return ''
  end

  def sacctmgr_list_assoc(*args)
    self.class.sacctmgr_list_assoc(*args)
  end

  def self.parse_time(t)
    time = PuppetX::SLURM::Util.parse_time(t)
    return t if time.nil?
    time[3].to_i + (time[2].to_i * 60) + (time[1].to_i * 3600) + (time[0].to_i * 86_400)
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
      value = if raw_value.include?(',')
                raw_value.split(',')
              elsif raw_value == ''
                :absent
              else
                Array(raw_value)
              end
    elsif time_to_seconds.include?(property)
      value = parse_time(raw_value).to_s
    elsif raw_value == ''
      value = :absent
    elsif raw_value.include?('=')
      value = {}
      raw_value.split(',').each do |i|
        k, v = i.split('=')
        if v.to_s[-1] == 'M'
          v.chop!
        end
        value[k] = v.to_s
      end
    elsif raw_value.include?(',')
      value = raw_value.split(',')
    else
      value = raw_value
    end
    value
  end

  def parse_tres(value)
    tres = {}
    value.split(',').each do |val|
      k, v = val.split('=')
      tres[k] = v
    end
    tres
  end

  def set_values(create) # rubocop:disable Style/AccessorMethodName
    result = []
    properties = if create
                   type_params - [self.class.name_attribute] + type_properties
                 else
                   @property_flush.keys
                 end
    properties.each do |property|
      next if property_skip_set_values.include?(property.to_sym) && !create
      value = if create
                resource[property]
              else
                @property_flush[property]
              end
      next if (value == :absent || value == [:absent]) && create
      next if value.nil?
      if property_name_overrides.key?(property.to_sym)
        property = property_name_overrides[property]
      end
      name = property.to_s.delete('_')
      if !create && (value == :absent || value == [:absent])
        if property.to_s.include?('tres')
          current_value = @property_hash[property]
          next if current_value.nil?
          next if current_value == :absent
          new_tres = {}
          current_value.each_pair do |k, _v|
            new_tres[k] = '-1'
          end
          value = new_tres.map { |k, v| "#{k}=#{v}" }.join(',')
        else
          value = set_absent_values[property] || '-1'
        end
      elsif value.is_a?(Array)
        value = value.join(',')
      elsif value.is_a?(Hash)
        current_value = @property_hash[property] || {}
        current_value = {} if current_value == :absent
        current_value.each_pair do |k, _v|
          unless value.key?(k)
            value[k] = '-1'
          end
        end
        value = value.map { |k, v| "#{k}=#{v}" }.join(',')
      elsif value.is_a?(String)
        if value =~ %r{\s}
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
    sacctmgr(['-i', 'create', sacctmgr_resource, @resource[self.class.name_attribute], set_values(true)].flatten)
    @property_hash[:ensure] = :present
  end

  def flush
    unless @property_flush.empty?
      cmd = ['-i', 'modify', sacctmgr_resource, 'where', "name=#{@resource[self.class.name_attribute]}"]
      if sacctmgr_resource == 'account'
        cmd << "cluster=#{@resource[:cluster]}"
      elsif sacctmgr_resource == 'user'
        cmd << "account=#{@resource[:account]}"
        cmd << "cluster=#{@resource[:cluster]}"
      elsif sacctmgr_resource == 'resource'
        cmd << "server=#{@resource[:server]}"
        cmd << "cluster=#{@resource[:cluster]}" if @resource[:cluster]
      end
      cmd << 'set'
      values = set_values(false)
      cmd << values
      unless values.empty?
        sacctmgr(cmd.flatten)
      end
      property_skip_set_values.each do |p|
        send("set_#{p}")
      end
    end
    @property_hash = resource.to_hash
  end

  def destroy
    cmd = ['-i', 'delete', sacctmgr_resource, 'where', "name=#{@resource[self.class.name_attribute]}"]
    # Resource specific behavior
    # If cluster is 'absent' then delete the entire account without cluster filter
    if sacctmgr_resource == 'account'
      if @resource[:cluster] && @resource[:cluster].to_s == 'absent'
        Puppet.notice("Slurm_account[#{@resource[:name]}] Removing all accounts by name #{@resource[:name]}")
      else
        cmd << "cluster=#{@resource[:cluster]}"
      end
    # If cluster and account are 'absent' then delete the entire user without cluster and account filter
    elsif sacctmgr_resource == 'user'
      if (@resource[:account] && @resource[:account].to_s == 'absent') &&
         (@resource[:cluster] && @resource[:cluster].to_s == 'absent')
        Puppet.notice("Slurm_user[#{@resource[:name]}] Removing all users by name #{@resource[:name]}")
      else
        cmd << "account=#{@resource[:account]}"
        cmd << "cluster=#{@resource[:cluster]}"
        if @resource[:partition].to_s != 'absent'
          cmd << "partition=#{@resource[:partition]}"
        end
      end
    elsif sacctmgr_resource == 'resource'
      cmd << "server=#{@resource[:server]}"
      cmd << "cluster=#{@resource[:cluster]}" if @resource[:cluster]
    end
    sacctmgr(cmd.flatten)
    @property_hash.clear
  end
end
