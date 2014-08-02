Puppet::Type.newtype(:slurm_cluster) do
  @doc =<<-EOS
Puppet type that manages a SLURM cluster"

EOS

  ensurable do
    desc <<-EOS
      Manage the existance of this cluster.  The default action is *present*.
    EOS

    newvalue(:present)
    newvalue(:absent)
    defaultto(:present)
  end

  newparam(:name) do
    desc "cluster name"

    munge { |value| value.downcase }
    isnamevar
  end

end
