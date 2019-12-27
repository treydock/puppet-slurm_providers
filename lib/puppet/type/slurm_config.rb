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

  newparam(:scontrol_path) do
    desc 'The path to scontrol'
    defaultto('scontrol')
  end

  def generate
    sacctmgr_types = []
    scontrol_types = []
    Dir[File.join(File.dirname(__FILE__), '../provider/slurm_*/sacctmgr.rb')].each do |file|
      type = File.basename(File.dirname(file))
      sacctmgr_types << type.to_sym
    end
    Dir[File.join(File.dirname(__FILE__), '../provider/slurm_*/scontrol.rb')].each do |file|
      type = File.basename(File.dirname(file))
      scontrol_types << type.to_sym
    end
    sacctmgr_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:sacctmgr)
      provider_class.sacctmgr_path = self[:sacctmgr_path]
    end
    scontrol_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:scontrol)
      provider_class.scontrol_path = self[:scontrol_path]
    end
    []
  end
end
