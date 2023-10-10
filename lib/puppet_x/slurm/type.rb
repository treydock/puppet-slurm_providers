# frozen_string_literal: true

module PuppetX # rubocop:disable Style/ClassAndModuleChildren
  module SLURM
    # Module for shared type configs
    module Type
      def add_autorequires(cluster = true, slurmdbd = true, slurmctld = false)
        if cluster
          autorequire(:slurm_cluster) do
            requires = []
            catalog.resources.each do |resource|
              if resource.instance_of?(::Puppet::Type::Slurm_cluster)
                requires << resource.name
              end
            end
            requires
          end
        end

        autorequire(:service) do
          ['slurmctld', 'slurmdbd']
        end

        if slurmdbd
          autorequire(:slurmdbd_conn_validator) do
            requires = []
            catalog.resources.each do |resource|
              if resource.instance_of?(::Puppet::Type::Slurmdbd_conn_validator)
                requires << resource.name
              end
            end
            requires
          end
        end

        if slurmctld # rubocop:disable Style/GuardClause
          autorequire(:slurmctld_conn_validator) do
            requires = []
            catalog.resources.each do |resource|
              if resource.instance_of?(::Puppet::Type::Slurmctld_conn_validator)
                requires << resource.name
              end
            end
            requires
          end
        end
      end
    end
  end
end
