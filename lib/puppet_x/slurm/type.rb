module PuppetX # rubocop:disable Style/ClassAndModuleChildren
  module SLURM # rubocop:disable Style/ClassAndModuleChildren
    # Module for shared type configs
    module Type
      def add_autorequires(cluster = true)
        if cluster
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

        autorequire(:service) do
          ['slurmctld','slurmdbd']
        end
      end
    end
  end
end
