Puppet::Type.newtype(:slurm_qos) do
  @doc =<<-EOS
Puppet type that manages a SLURM QOS"

  EOS

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
      value.join(",")
    end

    def should_to_s(value)
      value.join(",")
    end

    defaultto ["-1"]
  end

  newproperty(:grp_cpus) do
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

  newproperty(:grp_nodes) do
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

  newproperty(:max_cpus) do
    desc <<-EOS
      QOS MaxCPUs
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_cpus_per_user) do
    desc <<-EOS
      QOS MaxCpusPerUser
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_jobs) do
    desc <<-EOS
      QOS MaxJobs
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_nodes) do
    desc <<-EOS
      QOS MaxNodes
    EOS

    munge { |value| value.to_s }
    newvalues(/^([0-9]+|-1)$/)
    defaultto "-1"
  end

  newproperty(:max_nodes_per_user) do
    desc <<-EOS
      QOS MaxNodesPerUser
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

    def is_to_s(value)
      value.join(",")
    end

    def should_to_s(value)
      value.join(",")
    end

    defaultto ["''"]
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
end
