require 'spec_helper_acceptance'

describe 'slurm_license' do
  format_string = 'name,cluster,server,type,count,description,allowed,servertype'

  context 'manage basic license' do
    context 'create' do
      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'matlab@server':
          ensure => 'present',
          count  => 100,
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|100|matlab|0|') }
      end
    end

    context 'update' do
      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'matlab@server':
          ensure => 'present',
          count  => 200,
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|200|matlab|0|') }
      end
    end

    context 'remove' do
      it 'runs successfully' do
        setup_pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'comsol@server': ensure => 'present', count => 100 }
        EOS
        pp = <<-EOS
        slurm_license { 'matlab@server for linux': ensure => 'absent' }
        EOS

        apply_manifest(setup_pp, catch_failures: true)
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command('sacctmgr list resource format=name,server --noheader --parsable2') do
        its(:stdout) { is_expected.not_to include('matlab|server') }
        its(:stdout) { is_expected.to include('comsol|server') }
      end
    end
  end

  context 'manage advanced license' do
    context 'create' do
      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'matlab@server':
          ensure      => 'present',
          count       => 100,
          server_type => 'flexlm',
        }
        slurm_license { 'matlab@server for linux':
          ensure          => 'present',
          percent_allowed => 50,
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|100|matlab|0|flexlm') }
      end
      describe command("sacctmgr list resource format=#{format_string} withclusters --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab|linux|server|License|100|matlab|50|flexlm') }
      end
    end

    context 'update' do
      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'matlab@server':
          ensure      => 'present',
          count       => 200,
          server_type => 'flexlm',
        }
        slurm_license { 'matlab@server for linux':
          ensure          => 'present',
          percent_allowed => 100,
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|200|matlab|0|flexlm') }
      end
      describe command("sacctmgr list resource format=#{format_string} withclusters --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab|linux|server|License|200|matlab|100|flexlm') }
      end
    end
  end

  describe 'purging' do
    it 'runs successfully' do
      setup_pp = <<-EOS
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_license { 'comsol@server': ensure => 'present', count => 100 }
      slurm_license { 'matlab@server': ensure => 'present', count => 100 }
      EOS
      pp = <<-EOS
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_license { 'comsol@server': ensure => 'present', count => 100 }
      resources { 'slurm_license': purge => true }
      EOS

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('sacctmgr list resource format=name,server --noheader --parsable2') do
      its(:stdout) { is_expected.not_to include('matlab|server') }
      its(:stdout) { is_expected.to include('comsol|server') }
    end
  end

  describe 'cleanup' do
    it 'runs successfully' do
      pp = <<-EOS
      resources { 'slurm_license': purge => true }
      EOS

      apply_manifest(pp, catch_failures: true)
    end
  end
end
