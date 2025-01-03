# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'scontrol'))

Puppet::Type.type(:slurm_reservation).provide(:scontrol, parent: Puppet::Provider::Scontrol) do
  desc 'SLURM reservation type provider'

  mk_resource_methods

  def set_absent_values
    {}
  end

  def self.absent_values
    {}
  end

  def self.hash_colon_properties
    [:licenses]
  end

  def self.array_properties
    [:accounts, :flags, :users]
  end

  def self.rm_array_values
    {
      flags: ['SPEC_NODES', 'ALL_NODES'],
    }
  end

  def self.ignore_params
    [:timezone]
  end

  def skip_update_values
    [:flags]
  end

  def not_rm_flags
    [
      'FIRST_CORES', 'NO_HOLD_JOBS_AFTER', 'OVERLAP', 'REPLACE', 'REPLACE_DOWN',
    ]
  end

  def custom_env
    env = {}
    env['TZ'] = resource[:timezone] if resource[:timezone]
    env
  end

  def self.instances
    reservations = []
    scontrol_list.each_line do |line|
      Puppet.debug("slurm_reservation instances: LINE=#{line}")
      next unless line =~ %r{^ReservationName}

      values = line.chomp.split(' ')
      reservation = {}
      reservation[:ensure] = :present
      values.each do |v|
        key, raw_value = v.split('=', 2)
        if key == 'ReservationName'
          reservation[:name] = raw_value
          next
        end
        key = convert_scontrol_key(key)
        property = key.to_sym
        next unless type_properties.include?(property)

        Puppet.debug("slurm_reservation instances: key=#{key} raw_value=#{raw_value}")
        value = parse_value(property, raw_value.to_s)
        if rm_array_values.key?(property) && value != :absent
          rm_array_values[property].each do |rm_value|
            value.delete(rm_value)
          end
        end
        Puppet.debug("slurm_reservation instances: key=#{key} value=#{value}(#{value.class})")
        reservation[property] = value
      end
      reservations << new(reservation)
    end
    reservations
  end

  def self.prefetch(resources)
    reservations = instances
    resources.each_key do |name|
      provider = reservations.find { |c| c.name == name }
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

  def start_time
    value = @property_hash[:start_time]
    output = scontrol_show(resource[:name])
    values = output.chomp.split(' ')
    values.each do |v|
      key, raw_value = v.split('=', 2)
      next unless key == 'StartTime'

      value = raw_value
    end
    value
  end

  def end_time
    value = @property_hash[:end_time]
    output = scontrol_show(resource[:name])
    values = output.chomp.split(' ')
    values.each do |v|
      key, raw_value = v.split('=', 2)
      next unless key == 'EndTime'

      value = raw_value
    end
    value
  end

  def flags_update(current, new_flags)
    flags = []
    current_hash = if current == :absent
                     {}
                   else
                     Hash[current.map do |c|
                       k, v = c.split('=')
                       [k.upcase, v]
                     end]
                   end
    new_hash = Hash[new_flags.map do |c|
      k, v = c.split('=')
      [k.upcase, v]
    end]

    # Find which flags need to be removed with
    # flags-=<flag>
    current_hash.each_pair do |key, _value|
      if !new_hash.keys.include?(key) && !not_rm_flags.include?(key)
        flags << "flags-=#{key}"
      end
    end
    # Find which flags to either add or update
    new_hash.each_pair do |key, value|
      if !current_hash.keys.include?(key)
        flags << "flags=#{key}"
      elsif current_hash.keys.include?(key) && current_hash[key] != value
        flags << "flags=#{key}=#{value}"
      end
    end
    flags
  end

  def flush
    unless @property_flush.empty?
      flags = if !@property_flush[:flags].nil?
                flags_update(@property_hash[:flags], @property_flush[:flags])
              else
                nil
              end
      values = set_values(false)
      values << flags unless flags.nil?
      scontrol(['update', "#{scontrol_name_key}=#{@resource[:name]}", values].flatten, custom_env)
    end
    @property_hash = resource.to_hash
  end
end
