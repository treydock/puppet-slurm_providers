# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'slurm_reservation' do
  context 'when create basic reservation' do
    it 'runs successfully' do
      setup_pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_account { 'test1 on linux': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      PP
      pp = <<-PP
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
      slurm_reservation { 'test2':
        ensure     => 'present',
        start_time => '13:00:00',
        duration   => '00:45:00',
        node_cnt   => 1,
        features   => 'foo&bar',
        accounts   => ['test1','test2'],
        flags      => ['DAILY','PURGE_COMP=00:05:00','MAINT'],
        timezone   => 'UTC',
      }
      slurm_reservation { 'test3':
        ensure     => 'present',
        start_time => '11:00:00',
        duration   => '00:45:00',
        node_cnt   => 1,
        features   => 'foo&bar',
        accounts   => ['test1','test2'],
        flags      => ['HOURLY','PURGE_COMP=00:05:00','MAINT'],
        timezone   => 'UTC',
      }
      PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('scontrol show reservation=maint --oneliner') do
      its(:stdout) { is_expected.to match(%r{Duration=02:00:00}) }
      its(:stdout) { is_expected.to match(%r{Users=root}) }
      its(:stdout) { is_expected.to match(%r{Flags=MAINT,IGNORE_JOBS}) }
    end

    it 'created reservation' do
      on hosts, 'scontrol show reservation=test --oneliner' do
        expect(stdout).to match(%r{StartTime=[0-9-]+T14:00:00})
        expect(stdout).to match(%r{Duration=00:45:00})
        expect(stdout).to match(%r{Accounts=test1,test2})
        m = stdout.match(%r{Flags=([^ ]+)})
        flags = m[1]
        expect(flags).to include('DAILY')
        expect(flags).to include('MAINT')
        expect(flags).to include('PURGE_COMP=00:05:00')
      end
    end

    it 'created reservation using UTC' do
      on hosts, 'scontrol show reservation=test2 --oneliner' do
        hour = (13 + RSpec.configuration.timezone_offset).to_s.rjust(2, '0')
        expect(stdout).to match(%r{StartTime=[0-9-]+T#{hour}:00:00})
        expect(stdout).to match(%r{Duration=00:45:00})
        expect(stdout).to match(%r{Accounts=test1,test2})
        m = stdout.match(%r{Flags=([^ ]+)})
        flags = m[1]
        expect(flags).to include('DAILY')
        expect(flags).to include('MAINT')
        expect(flags).to include('PURGE_COMP=00:05:00')
      end
    end

    it 'created hourly reservation' do
      on hosts, 'scontrol show reservation=test3 --oneliner' do
        m = stdout.match(%r{Flags=([^ ]+)})
        flags = m[1]
        expect(flags).to include('HOURLY')
      end
    end
  end

  context 'when updates basic reservation' do
    it 'runs successfully' do
      setup_pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_account { 'test1 on linux': ensure => 'present' }
      slurm_account { 'test2 on linux': ensure => 'present' }
      slurm_account { 'test3 on linux': ensure => 'present' }
      PP
      pp = <<-PP
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
      slurm_reservation { 'test2':
        ensure     => 'present',
        start_time => '16:00:00',
        duration   => '02:00:00',
        node_cnt   => 1,
        features   => 'foo&bar',
        accounts   => ['test3'],
        flags      => ['DAILY','PURGE_COMP=00:15:00','MAINT'],
        timezone   => 'UTC',
      }
      slurm_reservation { 'test3':
        ensure     => 'present',
        start_time => '12:00:00',
        duration   => '00:50:00',
        node_cnt   => 1,
        features   => 'foo&bar',
        accounts   => ['test1','test2'],
        flags      => ['HOURLY','PURGE_COMP=00:05:00','MAINT'],
        timezone   => 'UTC',
      }
      PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('scontrol show reservation=maint --oneliner') do
      its(:stdout) { is_expected.to match(%r{Duration=04:00:00}) }
      its(:stdout) { is_expected.to match(%r{Users=root}) }
      its(:stdout) { is_expected.to match(%r{Flags=MAINT,IGNORE_JOBS}) }
    end

    it 'created reservation' do
      on hosts, 'scontrol show reservation=test --oneliner' do
        expect(stdout).to match(%r{StartTime=[0-9-]+T15:00:00})
        expect(stdout).to match(%r{Duration=01:00:00})
        expect(stdout).to match(%r{Accounts=test1,test2,test3})
        m = stdout.match(%r{Flags=([^ ]+)})
        flags = m[1]
        expect(flags).to include('DAILY')
        expect(flags).to include('MAINT')
        expect(flags).to include('PURGE_COMP=00:10:00')
      end
    end

    it 'created reservation using UTC' do
      on hosts, 'scontrol show reservation=test2 --oneliner' do
        hour = (16 + RSpec.configuration.timezone_offset).to_s.rjust(2, '0')
        expect(stdout).to match(%r{StartTime=[0-9-]+T#{hour}:00:00})
        expect(stdout).to match(%r{Duration=02:00:00})
        expect(stdout).to match(%r{Accounts=test3})
        m = stdout.match(%r{Flags=([^ ]+)})
        flags = m[1]
        expect(flags).to include('DAILY')
        expect(flags).to include('MAINT')
        expect(flags).to include('PURGE_COMP=00:15:00')
      end
    end
  end

  context 'with error handling' do
    it 'runs successfully' do
      setup_pp = <<-PP
      slurm_cluster { 'linux': ensure => 'present' }
      slurm_account { 'test1 on linux': ensure => 'present' }
      PP
      pp = <<-PP
      slurm_reservation { 'test':
        ensure     => 'present',
        start_time => '15:00:00',
        duration   => '01:00:00',
        node_cnt   => 5,
        features   => 'dne',
        accounts   => ['test3'],
        flags      => ['DAILY','PURGE_COMP=00:10:00','MAINT']
      }
      PP

      apply_manifest(setup_pp, catch_failures: true)
      apply_manifest(pp, expect_failures: true)
    end
  end

  context 'when removes reservation' do
    it 'runs successfully' do
      pp = <<-PP
      slurm_reservation { 'maint': ensure => 'absent' }
      slurm_reservation { 'test': ensure => 'absent' }
      slurm_reservation { 'test2': ensure => 'absent' }
      slurm_reservation { 'test3': ensure => 'absent' }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('scontrol show res --oneliner') do
      its(:stdout) { is_expected.not_to match(%r{^ReservationName=maint}) }
      its(:stdout) { is_expected.not_to match(%r{^ReservationName=test }) }
      its(:stdout) { is_expected.not_to match(%r{^ReservationName=test2}) }
      its(:stdout) { is_expected.not_to match(%r{^ReservationName=test3}) }
    end
  end
end
