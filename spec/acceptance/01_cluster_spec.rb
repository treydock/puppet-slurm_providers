# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'slurm_cluster' do
  context 'when create basic cluster' do
    it 'runs successfully' do
      pp = <<-PP
      slurmctld_conn_validator { 'puppet': }
      slurmdbd_conn_validator { 'puppet': }
      slurm_cluster { 'test': ensure => 'present' }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('sacctmgr list cluster format=cluster,flags,features,fedstate,federation --noheader --parsable2') do
      its(:stdout) { is_expected.to match(%r{^test||NA||None$}) }
    end
  end

  context 'when removes cluster' do
    it 'runs successfully' do
      pp = <<-PP
      slurm_cluster { 'test': ensure => 'absent' }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('sacctmgr show cluster test --noheader --parsable2') do
      its(:stdout) { is_expected.to eq('') }
    end
  end
end
