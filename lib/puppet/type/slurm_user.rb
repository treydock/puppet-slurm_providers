require_relative '../../puppet_x/slurm/type'
require_relative '../../puppet_x/slurm/array_property'
require_relative '../../puppet_x/slurm/float_property'
require_relative '../../puppet_x/slurm/hash_property'
require_relative '../../puppet_x/slurm/integer_property'
require_relative '../../puppet_x/slurm/time_property'

Puppet::Type.newtype(:slurm_user) do
  desc <<-DESC
Puppet type that manages a SLURM user
@example Add SLURM user under account 'bar' on cluster 'test'
  slurm_user { 'foo under bar on test':
    ensure    => 'present',
    max_jobs  => 1000,
    priority  => 9999,
  }

@example Add SLURM user under account 'bar' on cluster 'test'
  slurm_user { 'foo:bar:test':
    ensure    => 'present',
    max_jobs  => 1000,
    priority  => 9999,
  }
  DESC

  extend PuppetX::SLURM::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'User name'

    munge { |value| value.downcase }
  end

  newparam(:user, namevar: true) do
    desc 'User name'

    munge { |v| v.downcase }
    defaultto do
      @resource[:name]
    end
  end

  newparam(:account, namevar: true) do
    desc 'Account name'

    munge { |v| v.downcase }
  end

  newparam(:cluster, namevar: true) do
    desc 'Cluster name'
    munge { |v| v.downcase }
  end

  newparam(:partition, namevar: true) do
    desc 'Partition name'
    defaultto(:absent)
    munge { |v| v.downcase }
  end

  newproperty(:admin_level) do
    desc 'AdminLevel'
    newvalues('None', 'Operator', 'Administrator')
    defaultto('None')
    munge { |v| v.to_s }
  end

  newproperty(:default_account) do
    desc 'DefaultAccount'
    munge { |v| v.downcase }
  end

  newproperty(:default_qos) do
    desc 'DefaultQOS'
  end

  newproperty(:fairshare) do
    desc 'Fairshare number or "parent"'
    defaultto(1)
  end

  newproperty(:grp_tres_mins, parent: PuppetX::SLURM::HashProperty) do
    desc 'GrpTRESMins'
    defaultto(:absent)
  end

  newproperty(:grp_tres_run_mins, parent: PuppetX::SLURM::HashProperty) do
    desc 'GrpTRESRunMins'
    defaultto(:absent)
  end

  newproperty(:grp_tres, parent: PuppetX::SLURM::HashProperty) do
    desc 'GrpTRES'
    defaultto(:absent)
  end

  newproperty(:grp_jobs, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'GrpJobs'
    defaultto(:absent)
  end

  newproperty(:grp_jobs_accrue, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'GrpJobsAccrue'
    defaultto(:absent)
  end

  newproperty(:grp_submit_jobs, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'GrpSubmitJobs'
    defaultto(:absent)
  end

  newproperty(:grp_wall, parent: PuppetX::SLURM::TimeProperty) do
    desc 'GrpWall'
    defaultto(:absent)
  end

  newproperty(:max_tres_mins_per_job, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresMinsPerJob'
    defaultto(:absent)
  end

  newproperty(:max_tres_per_job, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresPerJob'
    defaultto(:absent)
  end

  newproperty(:max_tres_per_node, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresPerJob'
    defaultto(:absent)
  end

  newproperty(:max_jobs, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MaxJobs'
    defaultto(:absent)
  end

  newproperty(:max_jobs_accrue, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MaxJobsAccrue'
    defaultto(:absent)
  end

  newproperty(:max_submit_jobs, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MaxSubmitJobs'
    defaultto(:absent)
  end

  newproperty(:max_wall_duration_per_job, parent: PuppetX::SLURM::TimeProperty) do
    desc 'MaxWallDurationPerJob'
    defaultto(:absent)
  end

  newproperty(:priority, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'Priority'
  end

  newproperty(:qos, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc 'QOS, undefined will inherit parent QOS'
  end

  autorequire(:slurm_account) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s != 'Puppet::Type::Slurm_account'
        next
      end
      if resource[:cluster] == self[:cluster] && (resource[:account] == self[:account] ||
         resource[:account] == self[:default_account])
        requires << resource.name
      end
    end
    requires
  end
  autorequire(:slurm_qos) do
    self[:qos]
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) under (\S+) on (\S+))$},
        [
          [:name],
          [:user],
          [:account],
          [:cluster],
        ],
      ],
      [
        %r{^((\S+) under (\S+) on (\S+) partition (\S+))$},
        [
          [:name],
          [:user],
          [:account],
          [:cluster],
          [:partition],
        ],
      ],
      [
        %r{^(([^:]+):([^:]+):([^:]+))$},
        [
          [:name],
          [:user],
          [:account],
          [:cluster],
        ],
      ],
      [
        %r{^(([^:]+):([^:]+):([^:]+):([^:]+))$},
        [
          [:name],
          [:user],
          [:account],
          [:cluster],
          [:partition],
        ],
      ],
      [
        %r{(.*)},
        [
          [:name],
        ],
      ],
    ]
  end

  validate do
    if self[:cluster].nil?
      raise "Slurm_user[#{self[:name]}] must have cluster defined"
    end
    if self[:account].nil?
      raise "Slurm_user[#{self[:name]}] must have account defined"
    end
  end
end
