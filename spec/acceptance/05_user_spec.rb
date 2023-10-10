# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'slurm_user' do
  # Variable and let should be merged with provider unit test file
  type_params = [
    :user, :account, :cluster
  ]
  type_properties = [
    :admin_level, :default_account, :default_qos, :fairshare, :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs,
    :grp_tres, :grp_tres_mins, :grp_tres_run_mins,
    :grp_wall, :max_jobs, :max_jobs_accrue, :max_submit_jobs, :max_tres_mins_per_job, :max_tres_per_job, :max_tres_per_node,
    :max_wall_duration_per_job, :priority, :qos
  ]
  format_string = (type_params + type_properties).map { |p| p.to_s.delete('_') }.join(',')

  let(:name) { 'foo' }
  let(:defaults) do
    {
      user: name,
      cluster: 'linux',
      account: 'test',
      default_account: 'test',
      admin_level: 'None',
      fairshare: '1',
      qos: 'normal'
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

  context 'when manage basic user' do
    context 'when create' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { 'test on linux': ensure => 'present' }
        slurm_qos { 'debug': ensure => 'present' }
        slurm_user { '#{name} under test on linux': ensure => 'present' }
        slurm_user { '#{name} under test on linux partition general': ensure => 'present', qos => 'debug' }
        slurm_user { 'testuser under test on linux': admin_level => 'Administrator' }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list user format=#{format_string} withassoc --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end

      describe command('sacctmgr list user format=user,account,cluster,partition,qos withassoc --noheader --parsable') do
        its(:stdout) { is_expected.to include('foo|test|linux||normal|') }
        its(:stdout) { is_expected.to include('foo|test|linux|general|debug|') }
      end

      describe command('sacctmgr list user format=user,adminlevel --noheader --parsable2') do
        its(:stdout) { is_expected.to include('testuser|Administrator') }
      end
    end

    context 'when update' do
      let(:grp_tres) { 'cpu=1' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { 'test on linux': ensure => 'present' }
        slurm_user { '#{name} under test on linux': ensure => 'present', grp_tres => {'cpu' => 1} }
        slurm_user { '#{name} under test on linux partition general': ensure => 'present', qos => 'normal', grp_tres => {'cpu' => 1} }
        slurm_user { 'testuser under test on linux': admin_level => 'Operator' }
        slurm_user { 'testuser2 under test on linux': ensure => 'present', qos => 'normal', grp_tres => {'cpu' => 1} }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list user format=#{format_string} withassoc --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end

      describe command('sacctmgr list user format=user,account,cluster,partition,qos,grptres withassoc --noheader --parsable') do
        its(:stdout) { is_expected.to include('foo|test|linux||normal|cpu=1|') }
        its(:stdout) { is_expected.to include('foo|test|linux|general|normal|cpu=1|') }
        its(:stdout) { is_expected.to include('testuser2|test|linux||normal|cpu=1|') }
      end

      describe command('sacctmgr list user format=user,adminlevel --noheader --parsable2') do
        its(:stdout) { is_expected.to include('testuser|Operator') }
      end
    end

    context 'when remove' do
      it 'runs successfully' do
        setup_pp = <<-PP
        slurm_cluster { 'linux2': ensure => 'present' }
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { 'def on linux': ensure => 'present' }
        slurm_account { 'def on linux2': ensure => 'present' }
        slurm_account { 'test on linux': ensure => 'present' }
        slurm_account { 'test2 on linux2': ensure => 'present' }
        slurm_user { '#{name} under def on linux2': ensure => 'present', default_account => 'def' }
        slurm_user { '#{name} under def on linux': ensure => 'present', default_account => 'def' }
        slurm_user { '#{name} under test2 on linux2': ensure => 'present', default_account => 'def' }
        slurm_user { '#{name} under test on linux': ensure => 'present', default_account => 'def' }
        slurm_user { 'baz under test on linux': ensure => 'present' }
        slurm_user { 'baz under test on linux partition general': ensure => 'present' }
        slurm_user { 'testuser2 under test on linux': ensure => 'present', qos => 'normal', grp_tres => 'absent' }
        PP
        pp = <<-PP
        slurm_user { '#{name} under test on linux': ensure => 'absent' }
        slurm_user { 'baz under test on linux partition general': ensure => 'absent' }
        PP

        apply_manifest(setup_pp, catch_failures: true)
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list user format=#{format_string} withassoc --noheader --parsable2") do
        its(:stdout) { is_expected.not_to include(value) }
      end

      describe command('sacctmgr list user format=user,account,cluster withassoc --noheader --parsable2') do
        its(:stdout) { is_expected.to include("#{name}|test2|linux2") }
      end

      describe command('sacctmgr list user format=user,account,cluster,partition,grptres withassoc --noheader --parsable') do
        its(:stdout) { is_expected.to include('baz|test|linux|||') }
        its(:stdout) { is_expected.to include('testuser2|test|linux|||') }
        its(:stdout) { is_expected.not_to include('baz|test|linux|general||') }
      end
    end
  end

  context 'when manage advanced user' do
    context 'when create' do
      let(:grp_tres) { 'cpu=700,node=20' }
      let(:max_tres_per_job) { 'cpu=200,node=10' }
      let(:max_jobs) { '100' }
      let(:priority) { '1000000' }
      let(:default_account) { 'def' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { 'test on linux': ensure => 'present' }
        slurm_user { '#{name} under test on linux':
          ensure            => 'present',
          grp_tres          => { 'cpu' => 700, 'node' => 20 },
          max_tres_per_job  => { 'cpu' => 200, 'node' => 10 },
          max_jobs          => 100,
          priority          => 1000000,
          default_account   => '#{default_account}',
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list user format=#{format_string} withassoc --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'when update' do
      let(:grp_tres) { 'node=40' }
      let(:max_tres_per_job) { 'node=20' }
      let(:max_jobs) { '200' }
      let(:priority) { '2000000' }
      let(:default_account) { 'def' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { 'test on linux': ensure => 'present' }
        slurm_user { '#{name} under test on linux':
          ensure            => 'present',
          grp_tres          => { 'node' => 40 },
          max_tres_per_job  => { 'node' => 20 },
          max_jobs          => 200,
          priority          => 2000000,
          default_account   => '#{default_account}',
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list user format=#{format_string} withassoc --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end
  end

  describe 'when purging' do
    it 'runs successfully' do
      setup_pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_cluster { 'linux2': ensure => 'present' }
      slurm_account { 'test on linux': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      slurm_account { 'test on linux2': ensure => 'present' }
      slurm_account { 'test2 on linux2': ensure => 'present' }
      slurm_account { 'def on linux': ensure => 'present' }
      slurm_account { 'def on linux2': ensure => 'present' }
      slurm_user { '#{name} under def on linux': ensure => 'present', default_account => 'def' }
      slurm_user { '#{name} under def on linux2': ensure => 'present', default_account => 'def' }
      slurm_user { '#{name} under test on linux': ensure => 'present', default_account => 'def' }
      slurm_user { '#{name} under test on linux2': ensure => 'present', default_account => 'def' }
      slurm_user { '#{name}2 under test2 on linux2': ensure => 'present' }
      PP
      pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_cluster { 'linux2': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      slurm_user { 'root under root on linux': ensure => 'present' }
      slurm_user { 'root under root on linux2': ensure => 'present' }
      slurm_user { '#{name} under def on linux': ensure => 'present', default_account => 'def' }
      slurm_user { '#{name} under def on linux2': ensure => 'present', default_account => 'def' }
      slurm_user { '#{name} under test on linux': ensure => 'present', default_account => 'def' }
      slurm_user { '#{name} under test on linux2': ensure => 'present', default_account => 'def' }
      resources { 'slurm_user': purge => true }
      PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
    end

    describe command("sacctmgr list user format=#{format_string} withassoc --noheader --parsable2") do
      its(:stdout) { is_expected.not_to include(value) }
    end

    describe command('sacctmgr list user format=user,account,cluster withassoc --noheader --parsable') do
      its(:stdout) { is_expected.to include("#{name}|test|linux|") }
      its(:stdout) { is_expected.to include("#{name}|test|linux2|") }
      its(:stdout) { is_expected.not_to include("#{name}2|test2|linux|") }
    end
  end
end
