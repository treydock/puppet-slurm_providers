require 'spec_helper_acceptance'

describe 'slurm_account' do
  # Variable and let should be merged with provider unit test file
  type_properties = [
    :cluster, :organization, :parent_name, :description, :default_qos, :fairshare, :grp_tres_mins, :grp_tres_run_mins, :grp_tres,
    :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs, :grp_wall, :max_tres_mins_per_job, :max_tres_per_job, :max_jobs, :max_jobs_accrue,
    :max_submit_jobs, :max_wall_duration_per_job, :priority, :qos_level
  ]
  format_string = 'account,' + type_properties.map { |p| p.to_s.delete('_') }.sort.join(',')

  let(:name) { 'test' }
  let(:defaults) do
    {
      cluster: 'linux',
      description: name,
      organization: name,
      parent_name: 'root',
      grace_time: '00:00:00',
      fairshare: '1',
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

  context 'manage basic account' do
    context 'create' do
      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux': ensure => 'present' }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'update' do
      let(:grp_tres) { 'cpu=1' }

      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux': ensure => 'present', grp_tres => {'cpu' => 1} }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'remove' do
      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux': ensure => 'absent' }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.not_to include(value) }
      end
    end
  end

  context 'manage advanced account' do
    context 'create' do
      let(:grp_tres) { 'cpu=700,node=20' }
      let(:max_tres_per_job) { 'cpu=200,node=10' }
      let(:max_jobs) { '100' }
      let(:priority) { '1000000' }

      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux':
          ensure            => 'present',
          grp_tres          => { 'cpu' => 700, 'node' => 20 },
          max_tres_per_job  => { 'cpu' => 200, 'node' => 10 },
          max_jobs          => 100,
          priority          => 1000000,
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end

    context 'update' do
      let(:grp_tres) { 'node=40' }
      let(:max_tres_per_job) { 'node=20' }
      let(:max_jobs) { '200' }
      let(:priority) { '2000000' }

      it 'runs successfully' do
        pp = <<-EOS
        slurm_cluster { 'linux': ensure => 'present' }
        slurm_account { '#{name} on linux':
          ensure            => 'present',
          grp_tres          => { 'node' => 40 },
          max_tres_per_job  => { 'node' => 20 },
          max_jobs          => 200,
          priority          => 2000000,
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
        its(:stdout) { is_expected.to include(value) }
      end
    end
  end

  describe 'purging' do
    let(:name) { 'test1' }

    it 'runs successfully' do
      setup_pp = <<-EOS
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_account { 'test1 on linux': ensure => 'present' }
      EOS
      pp = <<-EOS
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_account { 'root on linux': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      resources { 'slurm_account': purge => true }
      EOS

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command("sacctmgr list account format=#{format_string} withassoc where user= --noheader --parsable2") do
      its(:stdout) { is_expected.not_to include(value) }
    end
  end
end
