# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'slurm_qos' do
  # Variable and let should be merged with provider unit test file
  type_properties = [
    :description, :flags, :grace_time, :grp_tres_mins, :grp_tres_run_mins, :grp_tres,
    :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs, :grp_wall, :max_tres_mins, :max_tres_per_account,
    :max_tres_per_job, :max_tres_per_node, :max_tres_per_user, :max_jobs_per_account, :max_jobs_per_user,
    :max_submit_jobs_per_account, :max_submit_jobs_per_user, :max_wall, :min_prio_threshold, :min_tres_per_job,
    :preempt, :preempt_mode, :preempt_exempt_time, :priority, :usage_factor, :usage_threshold
  ]
  type_properties_format_string = type_properties.map { |p| p.to_s.delete('_') }.sort.join(',')
  format_string = "name,#{type_properties_format_string}"

  let(:name) { 'high' }
  let(:defaults) do
    {
      description: name,
      grace_time: '00:00:00',
      preempt_mode: 'cluster',
      priority: '0',
      usage_factor: '1.000000'
    }
  end
  let(:properties) { type_properties }
  let(:value) do
    values = [name]
    properties.sort.each do |p|
      v = send(p)
      values << v
    end
    values.join('|')
  end

  type_properties.each do |p|
    let(p) do
      if defaults.key?(p)
        defaults[p]
      else
        ''
      end
    end
  end

  context 'when manage basic QOS' do
    context 'when create' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_qos { '#{name}': ensure => 'present' }
        slurm_qos { 'preemptor': ensure => 'present', preempt => '#{name}' }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list qos format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to match(%r{^#{value}$}) }
      end

      describe command('sacctmgr list qos format=name,preempt --noheader --parsable2') do
        its(:stdout) { is_expected.to match(%r{^preemptor|#{name}$}) }
      end
    end

    context 'when update' do
      let(:grp_tres) { 'cpu=1' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_qos { '#{name}': ensure => 'present', grp_tres => {'cpu' => 1} }
        slurm_qos { 'preemptor': ensure => 'present' }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list qos format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to match(%r{^#{value}$}) }
      end

      describe command('sacctmgr list qos format=name,preempt --noheader --parsable2') do
        its(:stdout) { is_expected.to match(%r{^preemptor|$}) }
      end
    end

    context 'when remove' do
      it 'runs successfully' do
        pp = <<-PP
        slurm_qos { '#{name}': ensure => 'absent' }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list qos format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.not_to match(%r{^#{name}}) }
      end
    end
  end

  context 'when manage advanced QOS' do
    context 'when create' do
      let(:flags) { 'DenyOnLimit' }
      let(:grp_tres) { 'cpu=700,node=20' }
      let(:max_tres_per_user) { 'cpu=200,node=10' }
      let(:max_wall) { '1-00:00:00' }
      let(:priority) { '1000000' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_qos { '#{name}':
          ensure            => 'present',
          flags             => ['DenyOnLimit'],
          grp_tres          => { 'cpu' => 700, 'node' => 20 },
          max_tres_per_user => { 'cpu' => 200, 'node' => 10 },
          max_wall          => '1-00:00:00',
          priority          => 1000000,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list qos format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'when update' do
      let(:flags) { 'DenyOnLimit,RequiresReservation' }
      let(:grace_time) { '00:05:00' }
      let(:grp_tres) { 'node=40' }
      let(:max_tres_per_user) { 'node=20' }
      let(:max_wall) { '2-00:00:00' }
      let(:priority) { '2000000' }

      it 'runs successfully' do
        pp = <<-PP
        slurm_qos { '#{name}':
          ensure            => 'present',
          flags             => ['DenyOnLimit','RequiresReservation'],
          grace_time        => 300,
          grp_tres          => { 'node' => 40 },
          max_tres_per_user => { 'node' => 20 },
          max_wall          => '2-00:00:00',
          priority          => 2000000,
        }
        PP

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list qos format=#{format_string} --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end
  end

  describe 'when purging' do
    let(:name) { 'normal' }

    it 'runs successfully' do
      setup_pp = <<-PP
      slurm_qos { 'test1': ensure => 'present' }
      slurm_qos { 'test2': ensure => 'present' }
      PP
      pp = <<-PP
      slurm_qos { 'normal': ensure => 'present' }
      resources { 'slurm_qos': purge => true }
      PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command("sacctmgr list qos format=#{format_string} --noheader --parsable2") do
      its(:stdout) { is_expected.to eq("#{value}\n") }
    end
  end
end
