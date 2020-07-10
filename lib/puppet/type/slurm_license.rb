require_relative '../../puppet_x/slurm/type'
require_relative '../../puppet_x/slurm/array_property'
require_relative '../../puppet_x/slurm/float_property'
require_relative '../../puppet_x/slurm/hash_property'
require_relative '../../puppet_x/slurm/integer_property'
require_relative '../../puppet_x/slurm/time_property'

Puppet::Type.newtype(:slurm_license) do
  desc <<-DESC
Puppet type that manages a SLURM software resource
@example Add SLURM software resource
  slurm_license { 'matlab@host':
    ensure  => 'present',
    count   => 100,
  }
  slurm_license { 'matlab@host for linux':
    ensure          => 'present',
    percent_allowed => 100,
  }
  DESC

  extend PuppetX::SLURM::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'Resource name'

    munge { |value| value.downcase }
  end

  newparam(:resource_name, namevar: true) do
    desc 'Resource name'

    munge { |value| value.downcase }
    defaultto do
      @resource[:name]
    end
  end

  newparam(:server, namevar: true) do
    desc 'Server'

    munge { |value| value.downcase }
  end

  newparam(:cluster, namevar: true) do
    desc 'Cluster'
  end

  newparam(:type) do
    desc 'Resource type, read-only'
    defaultto('License')
    munge { |_value| 'License' }
  end

  newproperty(:description) do
    desc 'Description'
    defaultto do
      @resource[:resource_name]
    end
  end

  newproperty(:count, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'Count'
  end

  newproperty(:server_type) do
    desc 'ServerType'
    defaultto(:absent)
  end

  newproperty(:percent_allowed, parent: PuppetX::SLURM::IntegerProperty) do
    desc 'PercentAllowed'
  end

  autorequire(:slurm_license) do
    requires = []
    if self[:cluster]
      catalog.resources.each do |resource|
        if resource.class.to_s != 'Puppet::Type::Slurm_license'
          next
        end
        if resource[:count].nil?
          next
        end
        if resource[:resource_name] == self[:resource_name] && resource[:server] == self[:server]
          requires << resource.name
        end
      end
    end
    requires
  end

  def self.title_patterns
    [
      [
        %r{^(([^@]+)@(\S+) for (\S+))$},
        [
          [:name],
          [:resource_name],
          [:server],
          [:cluster],
        ],
      ],
      [
        %r{^(([^@]+)@(\S+))$},
        [
          [:name],
          [:resource_name],
          [:server],
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

  def pre_run_check
    return if self[:ensure].to_s == 'absent'

    if self[:server].nil?
      raise "Slurm_license[#{self[:name]}] must have server defined"
    end
    if self[:cluster].nil? && self[:count].nil?
      raise "Slurm_license[#{self[:name]}] must define at least cluster with percent_allowed or count"
    end
    if self[:cluster] && self[:percent_allowed].nil?
      raise "Slurm_license[#{self[:name]}] percent_allowed is required when cluster is set"
    end
    if self[:cluster] && self[:count]
      raise "Slurm_license[#{self[:name]}] Can not use count with cluster"
    end
    if self[:cluster] && self[:server_type].to_s != 'absent' # rubocop:disable Style/GuardClause
      raise "Slurm_license[#{self[:name]}] Can not use server_type with cluster"
    end
  end
end
