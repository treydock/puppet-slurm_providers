require 'spec_helper_acceptance'

describe 'slurm_config' do
  context 'setup' do
    it 'removes previous install' do
      on hosts, 'rm -f /usr/bin/sacctmgr'
      pp = <<-EOS
      class { '::slurm':
        conf_dir       => '/opt/slurm/etc',
        install_prefix => '/opt/slurm',
      }
      EOS
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'create basic cluster' do
    it 'runs successfully' do
      pp = <<-EOS
      slurm_config { 'puppet':
        install_prefix => '/opt/slurm',
      }
      slurm_cluster { 'linux': ensure => 'present' }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('/opt/slurm/bin/sacctmgr list cluster format=cluster,flags,features,fedstate,federation --noheader --parsable2') do
      its(:stdout) { is_expected.to match(%r{^linux||NA||None$}) }
    end
  end

  context 'removes cluster' do
    it 'runs successfully' do
      pp = <<-EOS
      slurm_config { 'puppet':
        install_prefix => '/opt/slurm',
      }
      slurm_cluster { 'linux': ensure => 'absent' }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('/opt/slurm/bin/sacctmgr show cluster linux --noheader --parsable2') do
      its(:stdout) { is_expected.to eq('') }
    end
  end
end
