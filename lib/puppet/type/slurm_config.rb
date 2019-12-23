Puppet::Type.newtype(:slurm_config) do
  desc <<-DESC
  @summary Abstract type to configure other SLURM types
DESC

  newparam(:name, namevar: true) do
    desc 'The name of the resource'
  end

  newparam(:sacctmgr_path) do
    desc 'The path to sacctmgr'
    defaultto('sacctmgr')
  end

  def generate
    sacctmgr_types = []
    Dir[File.join(File.dirname(__FILE__), '../provider/slurm_*/sacctmgr.rb')].each do |file|
      type = File.basename(File.dirname(file))
      sacctmgr_types << type.to_sym
    end
    sacctmgr_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:sacctmgr)
      provider_class.sacctmgr_path = self[:sacctmgr_path]
    end
    []
  end
end
