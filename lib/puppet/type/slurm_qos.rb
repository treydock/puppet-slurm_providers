Puppet::Type.newtype(:slurm_qos) do
  @doc =<<-EOS
Puppet type that manages a SLURM QOS"

  EOS

  tres_types = [
    'cpu',
    'energy',
    'mem',
    'node',
  ]

  feature :slurm_without_tres, "The inability to set TRES"
  feature :slurm_with_tres, "The ability to set TRES"

  def initialize(*args)
    super
    if self[:ensure] == :present
      # Sort arrays to ensure consistent comparison
      if Array(self[:flags]).count > 1
        self[:flags] = Array(self[:flags]).uniq.sort!
      end

      if Array(self[:preempt]).count > 1
        self[:preempt] = Array(self[:preempt]).uniq.sort!
      end
    end
  end

  ensurable do
    desc <<-EOS
      Manage the existance of this QOS.  The default action is *present*.
    EOS

    newvalue(:present)
    newvalue(:absent)
    defaultto(:present)
  end

  newparam(:name) do
    desc "QOS name"

    munge { |value| value.downcase }
    isnamevar
  end

  newproperty(:description) do
    desc <<-EOS
      QOS Description
    EOS

    munge { |value| value.downcase }
    defaultto { @resource[:name] }
  end

  newproperty(:flags, :array_matching => :all) do
    desc <<-EOS
      QOS Flags
    EOS

    def is_to_s(value)
      if value == :absent or value.include?(:absent)
        super
      else
        value.join(",")
      end
    end

    def should_to_s(value)
      if value == :absent or value.include?(:absent)
        super
      else
        value.join(",")
      end
    end

    defaultto ["-1"]
  end

  # Define TRES properties

  tres_types.each do |tres_type|
    newproperty(:"grp_tres_#{tres_type}", :required_features => %w{slurm_with_tres}) do
      desc <<-EOS
      QOS GrpTRES type #{tres_type}
      EOS

      munge { |value| value.to_s }
      newvalues(/^([0-9]+|-1)$/)
      defaultto "-1"
    end

    newproperty(:"max_tres_per_job_#{tres_type}", :required_features => %w{slurm_with_tres}) do
      desc <<-EOS
      QOS MaxTRESPerJob type #{tres_type}
      EOS

      munge { |value| value.to_s }
      newvalues(/^([0-9]+|-1)$/)
      defaultto "-1"
    end

    newproperty(:"max_tres_per_user_#{tres_type}", :required_features => %w{slurm_with_tres}) do
      desc <<-EOS
      QOS MaxTRESPerUser type #{tres_type}
      EOS

      munge { |value| value.to_s }
      newvalues(/^([0-9]+|-1)$/)
      defaultto "-1"
    end

    newproperty(:"min_tres_per_job_#{tres_type}", :required_features => %w{slurm_with_tres}) do
      desc <<-EOS
      QOS MinTRESPerJob type #{tres_type}
      EOS

      munge { |value| value.to_s }
      newvalues(/^([0-9]+|-1)$/)
      if tres_type == 'cpu'
        defaultto "1"
      else
        defaultto "-1"
      end
    end
  end

  newproperty(:grp_cpu_mins, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS GrpCPUMins
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:grp_cpu_run_mins, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS GrpCPURunMins
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:grp_cpus, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS GrpCPUs
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:grp_jobs) do
    desc <<-EOS
      QOS GrpJobs
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:grp_memory, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS GrpMemory
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:grp_nodes, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS GrpNodes
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:grp_submit_jobs) do
    desc <<-EOS
      QOS GrpSubmitJobs
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_cpus, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS MaxCPUs per Job
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_cpus_per_user, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS MaxCpusPerUser
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_jobs) do
    desc <<-EOS
      QOS MaxJobs per user
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_nodes, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS MaxNodes per Job
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_nodes_per_user, :required_features => %w{slurm_without_tres}) do
    desc <<-EOS
      QOS MaxNodesPerUser
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_submit_jobs) do
    desc <<-EOS
      QOS MaxSubmitJobs
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_wall) do
    desc <<-EOS
      QOS MaxWall
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+:[0-9]{2}:[0-9]{2}|-1)$/)
    defaultto "-1"
  end

  newproperty(:preempt, :array_matching => :all) do
    desc <<-EOS
      QOS Preempt
    EOS

    defaultto ["''"]

    def is_to_s(value)
      if value == :absent or value.include?(:absent)
        super
      else
        value.join(",")
      end
    end

    def should_to_s(value)
      if value == :absent or value.include?(:absent)
        super
      else
        value.join(",")
      end
    end
  end

  newproperty(:preempt_mode) do
    desc <<-EOS
      QOS PreemptMode
    EOS

    newvalues(:cluster, :cancel, :checkpoint, :requeue)
    defaultto :cluster
  end

  newproperty(:priority) do
    desc <<-EOS
      QOS Priority
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "0"
  end

  newproperty(:usage_factor) do
    desc <<-EOS
      QOS UsageFactor
    EOS

    munge { |value| sprintf "%.6f", value.to_s }
    newvalues(/^([0-9]+.)?([0-9]+)$/)
    defaultto "1.000000"
  end

  #REF: http://www.practicalclouds.com/content/guide/puppet-types-and-providers-autorequiring-all-objects-certain-type
  # Auto require all Slurm_cluster resources.
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
