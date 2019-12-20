require_relative '../../puppet_x/slurm/type'
require_relative '../../puppet_x/slurm/array_property'
require_relative '../../puppet_x/slurm/float_property'
require_relative '../../puppet_x/slurm/hash_property'
require_relative '../../puppet_x/slurm/integer_property'

Puppet::Type.newtype(:slurm_qos) do
  desc <<-DESC
Puppet type that manages a SLURM QOS
@example Add SLURM QOS
  slurm_qos {

  }
  DESC

  extend PuppetX::SLURM::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'QOS name'

    munge { |value| value.downcase }
  end

  newproperty(:description) do
    desc 'Description'
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:flags, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc 'Flags'
    newvalues('DenyOnLimit', 'EnforceUsageThreshold', 'NoReserve', 'PartitionMaxNodes', 'PartitionMinNodes',
              'OverPartQOS', 'PartitionTimeLimit', 'RequiresReservation', 'NoDecay', 'UsageFactorSafe', :absent)
    munge do |value|
      return value if value == :absent
      value.to_s
    end
    defaultto(:absent)
  end

  newproperty(:grace_time) do
    desc 'GraceTime'
    defaultto('00:00:00')
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

  newproperty(:grp_wall) do
    desc 'GrpWall'
    defaultto(:absent)
  end

  newproperty(:max_tres_mins, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresMins'
    defaultto(:absent)
  end

  newproperty(:max_tres_per_account, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresPerAccount'
    defaultto(:absent)
  end

  newproperty(:max_tres_per_job, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresPerJob'
    defaultto(:absent)
  end

  newproperty(:max_tres_per_node, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresPerNode'
    defaultto(:absent)
  end

  newproperty(:max_tres_per_user, parent: PuppetX::SLURM::HashProperty) do
    desc 'MaxTresPerUser'
    defaultto(:absent)
  end

  newproperty(:max_jobs_per_account, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MaxJobsPerAccount'
    defaultto(:absent)
  end

  newproperty(:max_jobs_per_user, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MaxJobsPerUser'
    defaultto(:absent)
  end

  newproperty(:max_submit_jobs_per_account, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MaxSubmitJobsPerAccount'
    defaultto(:absent)
  end

  newproperty(:max_submit_jobs_per_user, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MaxSubmitJobsPerUser'
    defaultto(:absent)
  end

  newproperty(:max_wall) do
    desc 'MaxWall'
    defaultto(:absent)
  end

  newproperty(:min_prio_threshold, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'MinPrioThreshold'
    defaultto(:absent)
  end

  newproperty(:min_tres_per_job, parent: PuppetX::SLURM::HashProperty) do
    desc 'MinTRESPerJob'
    defaultto(:absent)
  end

  newproperty(:preempt, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc 'Preempt'
    defaultto(:absent)
  end

  newproperty(:preempt_mode) do
    desc 'PreemptMode'
    newvalues(:cluster, :cancel, :checkpoint, :requeue)
    defaultto :cluster
  end

  newproperty(:preempt_exempt_time) do
    desc 'PreemptExemptTime'
    defaultto(:absent)
  end

  newproperty(:priority, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'Priority'
    defaultto('0')
  end

  newproperty(:usage_factor, parent: PuppetX::SLURM::FloatProperty) do
    desc 'UsageFactor'
    defaultto '1.000000'
  end

  newproperty(:usage_threshold, parent: PuppetX::SLURM::FloatProperty) do
    desc 'UsageThreshold'
    defaultto(:absent)
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
end
