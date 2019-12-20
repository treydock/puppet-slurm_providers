require_relative '../../puppet_x/slurm/type'
require_relative '../../puppet_x/slurm/array_property'
require_relative '../../puppet_x/slurm/float_property'
require_relative '../../puppet_x/slurm/hash_property'
require_relative '../../puppet_x/slurm/integer_property'

Puppet::Type.newtype(:slurm_cluster) do
  desc <<-EOS
Puppet type that manages a SLURM cluster
@example Add a SLURM cluster
  slurm_cluster { 'test':
    ensure => 'present',
  }

EOS

  extend PuppetX::SLURM::Type
  add_autorequires(false)

  ensurable

  newparam(:name, namevar: true) do
    desc "cluster name"

    munge { |value| value.downcase }
  end

  newproperty(:features, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc "Features"
    defaultto(:absent)
  end

  newproperty(:federation) do
    desc "Federation"
    defaultto(:absent)
  end

  newproperty(:fed_state) do
    desc "FedState"
    newvalues(:active, :inactive, :drain, :drain_remove)
  end

  # TODO/NOTE: Unable to find a way to modify flags so only support creation time
  newparam(:flags) do
  # newproperty(:flags, array_matching: :all, parent: PuppetX::SLURM::ArrayProperty) do
    desc "Flags"
    # defaultto(:absent)
  end
end
