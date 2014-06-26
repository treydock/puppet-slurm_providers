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

  #REF: http://www.practicalclouds.com/content/guide/puppet-types-and-providers-autorequiring-all-objects-certain-type
  # Auto require all Slurm_qos resources.
  autorequire(:slurm_qos) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Slurm_qos'
        requires << resource.name
      end
    end
    requires
  end
end
