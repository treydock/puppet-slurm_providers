require 'spec_helper_acceptance'

describe 'slurm_reservation' do
  context 'create basic reservation' do
    it 'runs successfully' do
      setup_pp = <<-EOS
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_account { 'test1 on linux': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      EOS
      pp = <<-EOS
      slurm_reservation { 'maint':
        ensure     => 'present',
        start_time => 'now',
        duration   => '02:00:00',
        users      => ['root'],
        flags      => ['maint','ignore_jobs'],
        nodes      => 'ALL',
      }
      slurm_reservation { 'test':
        ensure     => 'present',
        start_time => '14:00:00',
        duration   => '00:45:00',
        node_cnt   => 1,
        features   => 'foo&bar',
        accounts   => ['test1','test2'],
        flags      => ['DAILY','PURGE_COMP=00:05:00','MAINT']
      }
      EOS

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('scontrol show res --oneliner') do
      its(:stdout) { is_expected.to match(%r{^ReservationName=maint}) }
      its(:stdout) { is_expected.to match(%r{Duration=02:00:00}) }
      its(:stdout) { is_expected.to match(%r{Users=root}) }
      its(:stdout) { is_expected.to match(%r{Flags=MAINT,IGNORE_JOBS}) }
    end
  end

  context 'updates basic reservation' do
    it 'runs successfully' do
      setup_pp = <<-EOS
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_account { 'test1 on linux': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      slurm_account { 'test3 on linux': ensure => 'present' }
      EOS
      pp = <<-EOS
      slurm_reservation { 'maint':
        ensure     => 'present',
        start_time => 'now',
        duration   => '04:00:00',
        users      => ['root'],
        flags      => ['maint','ignore_jobs'],
        nodes      => 'ALL',
      }
      slurm_reservation { 'test':
        ensure     => 'present',
        start_time => '15:00:00',
        duration   => '01:00:00',
        node_cnt   => 1,
        features   => 'foo&bar',
        accounts   => ['test1','test2','test3'],
        flags      => ['DAILY','PURGE_COMP=00:10:00','MAINT']
      }
      EOS

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('scontrol show res --oneliner') do
      its(:stdout) { is_expected.to match(%r{^ReservationName=maint}) }
      its(:stdout) { is_expected.to match(%r{Duration=04:00:00}) }
      its(:stdout) { is_expected.to match(%r{Users=root}) }
      its(:stdout) { is_expected.to match(%r{Flags=MAINT,IGNORE_JOBS}) }
    end
  end

  context 'removes reservation' do
    it 'runs successfully' do
      pp = <<-EOS
      slurm_reservation { 'maint': ensure => 'absent' }
      slurm_reservation { 'test': ensure => 'absent' }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('scontrol show res --oneliner') do
      its(:stdout) { is_expected.not_to match(%r{^ReservationName=maint}) }
    end
  end
end
