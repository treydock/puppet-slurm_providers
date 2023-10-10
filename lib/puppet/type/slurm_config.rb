# frozen_string_literal: true

Puppet::Type.newtype(:slurm_config) do
  desc <<-DESC
  @summary Abstract type to configure other SLURM types
  DESC

  newparam(:name, namevar: true) do
    desc 'The name of the resource'
  end

  newparam(:install_prefix) do
    desc 'The path to SLURM install prefix'
  end

  def generate
    sacctmgr_types = []
    scontrol_types = []
    sdiag_types = []
    Dir[File.join(File.dirname(__FILE__), '../provider/slurm*/sacctmgr.rb')].each do |file|
      type = File.basename(File.dirname(file))
      sacctmgr_types << type.to_sym
    end
    Dir[File.join(File.dirname(__FILE__), '../provider/slurm*/sdiag.rb')].each do |file|
      type = File.basename(File.dirname(file))
      sdiag_types << type.to_sym
    end
    Dir[File.join(File.dirname(__FILE__), '../provider/slurm_*/scontrol.rb')].each do |file|
      type = File.basename(File.dirname(file))
      scontrol_types << type.to_sym
    end
    sacctmgr_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:sacctmgr)
      provider_class.install_prefix = self[:install_prefix]
    end
    scontrol_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:scontrol)
      provider_class.install_prefix = self[:install_prefix]
    end
    sdiag_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:sdiag)
      provider_class.install_prefix = self[:install_prefix]
    end
    []
  end
end
