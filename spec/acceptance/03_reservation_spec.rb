require 'spec_helper_acceptance'

describe 'slurm_reservation' do
  context 'create basic reservation' do
    it 'runs successfully' do
      pp = <<-EOS
      slurm_reservation { 'maint':
        ensure     => 'present',
        start_time => 'now',
        duration   => '02:00:00',
        users      => ['root'],
        flags      => ['maint','ignore_jobs'],
        nodes      => 'ALL',
      }
      EOS

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
      pp = <<-EOS
      slurm_reservation { 'maint':
        ensure     => 'present',
        start_time => 'now',
        duration   => '04:00:00',
        users      => ['root'],
        flags      => ['maint','ignore_jobs'],
        nodes      => 'ALL',
      }
      EOS

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
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('scontrol show res --oneliner') do
      its(:stdout) { is_expected.not_to match(%r{^ReservationName=maint}) }
    end
  end
end
