# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'slurm_license' do
  format_string = 'name,cluster,server,type,count,description,allowed,servertype'

  context 'when manage basic license' do
    context 'when create' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'matlab@server':
          ensure => 'present',
          count  => 100,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|100|matlab|0|') }
      end
    end

    context 'when update' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'matlab@server':
          ensure => 'present',
          count  => 200,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|200|matlab|0|') }
      end
    end

    context 'when remove' do
      it 'runs successfully' do
        setup_pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'comsol@server': ensure => 'present', count => 100 }
        PP
        pp = <<-PP
        slurm_license { 'matlab@server for linux': ensure => 'absent' }
        PP

        apply_manifest(setup_pp, catch_failures: true)
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command('sacctmgr list resource format=name,server,cluster --noheader --parsable2') do
        its(:stdout) { is_expected.not_to include('matlab|server|linux') }
        its(:stdout) { is_expected.to include('comsol|server|') }
      end
    end
  end

  context 'when manage advanced license' do
    context 'when create' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'comsol@server': ensure => 'present', count => 100 }
        slurm_license { 'matlab@server':
          ensure      => 'present',
          count       => 100,
          server_type => 'flexlm',
        }
        slurm_license { 'matlab@server for linux':
          ensure          => 'present',
          percent_allowed => 50,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('comsol||server|License|100|comsol|0|') }
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|100|matlab|0|flexlm') }
      end

      describe command("sacctmgr list resource format=#{format_string} withclusters --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab|linux|server|License|100|matlab|50|flexlm') }
      end
    end

    context 'when update' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_license { 'comsol@server': ensure => 'present', count => 100 }
        slurm_license { 'comsol@server for linux':
          ensure          => 'present',
          percent_allowed => 100,
        }
        slurm_license { 'matlab@server':
          ensure      => 'present',
          count       => 200,
          server_type => 'flexlm',
        }
        slurm_license { 'matlab@server for linux':
          ensure          => 'present',
          percent_allowed => 100,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list resource format=#{format_string} withclusters --noheader --parsable2") do
        its(:stdout) { is_expected.to include('comsol|linux|server|License|100|comsol|100|') }
      end

      describe command("sacctmgr list resource format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab||server|License|200|matlab|0|flexlm') }
      end

      describe command("sacctmgr list resource format=#{format_string} withclusters --noheader --parsable2") do
        its(:stdout) { is_expected.to include('matlab|linux|server|License|200|matlab|100|flexlm') }
      end
    end
  end

  describe 'when purging' do
    it 'runs successfully' do
      setup_pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_license { 'comsol@server': ensure => 'present', count => 100 }
      slurm_license { 'matlab@server': ensure => 'present', count => 100 }
      PP
      pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_license { 'comsol@server': ensure => 'present', count => 100 }
      resources { 'slurm_license': purge => true }
      PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('sacctmgr list resource format=name,server --noheader --parsable2') do
      its(:stdout) { is_expected.not_to include('matlab|server') }
      its(:stdout) { is_expected.to include('comsol|server') }
    end
  end

  describe 'when cleanup' do
    it 'runs successfully' do
      pp = <<-PP
      resources { 'slurm_license': purge => true }
      PP

      apply_manifest(pp, catch_failures: true)
    end
  end
end
