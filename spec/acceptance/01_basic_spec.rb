require 'spec_helper_acceptance'

describe 'Slurm_cluster and Slurm_qos:' do
  context 'create basic cluster and QOS' do
    it 'should run successfully' do
      pp =<<-EOS
      slurm_cluster { 'linux': }
      slurm_qos { 'expedite': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe command('sacctmgr show cluster format=cluster --noheader --parsable2') do
      its(:stdout) { should match /^linux$/ }
    end

    describe command('sacctmgr show qos format=name --noheader --parsable2') do
      its(:stdout) { should match /^normal$/ }
      its(:stdout) { should match /^expedite$/ }
    end
  end

  context 'set preempt for QOS' do
    it 'should run successfully' do
      pp =<<-EOS
      slurm_cluster { 'linux': }
      slurm_qos { 'low': }
      slurm_qos { 'hi': preempt => ['low']}
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe command('sacctmgr show qos format=name,preempt --noheader --parsable2') do
      its(:stdout) { should match /^hi\|low$/ }
    end
  end
end
