# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'slurm_account' do
  # Variable and let should be merged with provider unit test file
  type_params = [
    :account, :cluster,
  ]
  type_properties = [
    :organization, :parent_name, :description, :default_qos, :fairshare, :grp_tres_mins, :grp_tres_run_mins, :grp_tres,
    :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs, :grp_wall, :max_tres_mins_per_job, :max_tres_per_job, :max_tres_per_node,
    :max_jobs, :max_jobs_accrue, :max_submit_jobs, :max_wall_duration_per_job, :priority, :qos,
  ]
  format_string = (type_params + type_properties).map { |p| p.to_s.delete('_') }.join(',')

  let(:name) { 'test' }
  let(:defaults) do
    {
      account: name,
      cluster: 'linux',
      organization: name,
      description: name,
      parent_name: 'root',
      grace_time: '00:00:00',
      qos: 'normal',
      fairshare: '1',
    }
  end
  let(:params) { type_params }
  let(:properties) { type_properties }
  let(:value) do
    values = []
    params.each do |p|
      v = send(p)
      values << v
    end
    properties.each do |p|
      v = send(p)
      values << v
    end
    values.join('|')
  end

  (type_params + type_properties).each do |p|
    let(p) do
      if defaults.key?(p)
        defaults[p]
      else
        ''
      end
    end
  end

  context 'when manage basic account' do
    context 'when create' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux': ensure => 'present' }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'when update' do
      let(:grp_tres) { 'cpu=1' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux': ensure => 'present', grp_tres => {'cpu' => 1} }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'when remove' do
      it 'runs successfully' do
        setup_pp = <<-PP
        slurm_cluster { 'linux2': ensure => 'present' }
        slurm_account { '#{name} on linux2': ensure => 'present' }
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux': ensure => 'present' }
        PP
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux': ensure => 'absent' }
        PP

        apply_manifest(setup_pp, catch_failures: true)
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.not_to include(value) }
      end

      describe command('sacctmgr list account format=account,cluster withassoc where user= --noheader --parsable2') do
        its(:stdout) { is_expected.to include("#{name}|linux2") }
      end
    end
  end

  context 'when manage advanced account' do
    context 'when create' do
      let(:grp_tres) { 'cpu=700,node=20' }
      let(:max_tres_per_job) { 'cpu=200,node=10' }
      let(:max_jobs) { '100' }
      let(:priority) { '1000000' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux':
          ensure            => 'present',
          grp_tres          => { 'cpu' => 700, 'node' => 20 },
          max_tres_per_job  => { 'cpu' => 200, 'node' => 10 },
          max_jobs          => 100,
          priority          => 1000000,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'when update' do
      let(:grp_tres) { 'node=40' }
      let(:max_tres_per_job) { 'node=20' }
      let(:max_jobs) { '200' }
      let(:priority) { '2000000' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux':
          ensure            => 'present',
          grp_tres          => { 'node' => 40 },
          max_tres_per_job  => { 'node' => 20 },
          max_jobs          => 200,
          priority          => 2000000,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end
  end

  describe 'when purging' do
    let(:name) { 'test1' }

    it 'runs successfully' do
      setup_pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_cluster { 'linux2': ensure => 'present' }
      slurm_account { '#{name} on linux': ensure => 'present' }
      slurm_account { '#{name} on linux2': ensure => 'present' }
      slurm_account { 'test2 on linux2': ensure => 'present' }
      PP
      pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_cluster { 'linux2': ensure => 'present' }
      slurm_account { 'root on linux': ensure => 'present' }
      slurm_account { 'root on linux2': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      resources { 'slurm_account': purge => true }
      PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      # Second puppet run will remove accounts that have no cluster assigned
      apply_manifest(pp, expect_changes: true)
    end

    describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
      its(:stdout) { is_expected.not_to include(value) }
    end

    describe command('sacctmgr list account format=account,cluster withassoc where user= --noheader --parsable') do
      its(:stdout) { is_expected.not_to include("#{name}|linux|") }
      its(:stdout) { is_expected.not_to include("#{name}|linux2|") }
      its(:stdout) { is_expected.not_to include('test2|linux2|') }
      its(:stdout) { is_expected.to include('test2|linux|') }
    end
  end
end
