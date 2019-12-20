require 'spec_helper_acceptance'

describe 'Slurm_cluster and Slurm_qos:' do
  context 'create basic cluster and QOS' do
    it 'should run successfully' do
      pp =<<-EOS
      resources { 'slurm_qos': purge => true }
      slurm_cluster { 'linux': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe command('sacctmgr show cluster format=cluster --noheader --parsable2') do
      its(:stdout) { should match /^linux$/ }
    end

    describe command('sacctmgr show qos format=name --noheader --parsable2') do
      its(:stdout) { should match /^$/ }
    end
  end
end
