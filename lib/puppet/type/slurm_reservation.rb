require_relative '../../puppet_x/slurm/type'
require_relative '../../puppet_x/slurm/array_property'
require_relative '../../puppet_x/slurm/float_property'
require_relative '../../puppet_x/slurm/hash_property'
require_relative '../../puppet_x/slurm/integer_property'
require_relative '../../puppet_x/slurm/time_property'

Puppet::Type.newtype(:slurm_reservation) do
  desc <<-DESC
Puppet type that manages a SLURM Reservation
@example Add SLURM Reservation
  slurm_reservation { 'maint':
    ensure     => 'present',
    start_time => 'now',
    duration   => '02:00:00',
    users      => ['root'],
    flags      => ['maint','ignore_jobs'],
    nodes      => 'ALL',
  }
  DESC

  extend PuppetX::SLURM::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'Reservation name'

    munge { |value| value.downcase }
  end

  newproperty(:accounts, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc 'Accounts'
  end

  newproperty(:burst_buffer) do
    desc 'BurstBuffer'
  end

  newproperty(:core_cnt) do
    desc 'CoreCnt'
  end

  newproperty(:licenses, parent: PuppetX::SLURM::HashProperty) do
    desc 'Licenses'
  end

  newproperty(:node_cnt) do
    desc 'NodeCnt'
  end

  newproperty(:nodes) do
    desc 'Nodes'
    def insync?(is)
      should = if @should.is_a?(Array)
                 @should[0]
               else
                 @should
               end
      if should =~ %r{ALL|all}
        return true
      end
      super(is)
    end
  end

  newproperty(:start_time) do
    desc 'StartTime'

    def insync?(is)
      should = if @should.is_a?(Array)
                 @should[0]
               else
                 @should
               end
      if should =~ %r{^(NOW|now)}
        return true
      end
      super(is)
    end
  end

  newproperty(:end_time) do
    desc 'EndTime'

    def insync?(is)
      should = if @should.is_a?(Array)
                 @should[0]
               else
                 @should
               end
      if should =~ %r{^(NOW|now)}
        return true
      end
      super(is)
    end
  end

  newproperty(:duration) do
    desc 'Duration'
  end

  newproperty(:partition_name) do
    desc 'PartitionName'
  end

  newproperty(:flags, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc 'Flags'
    validate do |value|
      valid_values = ['ANY_NODES', 'DAILY', 'FLEX', 'FIRST_CORES', 'IGNORE_JOBS', 'LICENSE_ONLY', 'MAINT', 'NO_HOLD_JOBS_AFTER',
                      'OVERLAP', 'PART_NODES', 'PURGE_COMP', 'REPLACE', 'REPLACE_DOWN', 'STATIC_ALLOC',
                      'TIME_FLOAT', 'WEEKDAY', 'WEEKEND', 'WEEKLY']
      unless valid_values.include?(value.upcase)
        raise "#{value} is not valid for flags"
      end
    end
    munge do |value|
      return value if value == :absent
      value.upcase.to_s
    end
  end

  newproperty(:features) do
    desc 'Features'
  end

  newproperty(:users, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc 'Users'
  end

  newproperty(:tres, parent: PuppetX::SLURM::HashProperty) do
    desc 'TRES'
  end

  autorequire(:slurm_cluster) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Slurm_cluster'
        requires << resource.name
      end
    end
    requires
  end

  validate do
    if self[:ensure] == :present
      if self[:start_time].nil?
        raise "slurm_reservation[#{self[:name]}]: Must specify start_time"
      end
      if self[:end_time].nil? && self[:duration].nil?
        raise "slurm_reservation[#{self[:name]}]: Must specify either end_time or duration"
      end
      if self[:licenses] && self[:node_cnt].nil? && self[:nodes].nil?
        flags = self[:flags] || []
        unless flags.include?('LICENSE_ONLY')
          raise "slurm_reservation[#{self[:name]}]: Reservation with licenses and no node_cnt or nodes must specifify flags with LICENSE_ONLY"
        end
      end
      if self[:accounts].nil? && self[:users].nil?
        raise "slurm_reservation[#{self[:name]}]: Must specify either accounts or users"
      end
    end
  end
end
