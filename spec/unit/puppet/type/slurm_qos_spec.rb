# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:slurm_qos) do
  let(:default_config) { { name: 'foo' } }
  let(:config) { default_config }
  let(:resource) { described_class.new(config) }

  it 'adds to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.not_to raise_error
  end

  it 'has a name' do
    expect(resource[:name]).to eq('foo')
  end

  defaults = {
    description: 'foo',
    grace_time: '0',
    usage_factor: '1.000000',
    priority: '0',
  }

  describe 'basic properties' do
    [
      :description,
    ].each do |p|
      it "accepts a #{p}" do
        config[p] = 'foo'
        expect(resource[p]).to eq('foo')
        config[p] = 'Foo'
        expect(resource[p]).to eq('foo')
      end

      default = defaults.key?(p) ? defaults[p] : :absent
      it "has default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'time properties' do
    [
      :grp_wall,
      :max_wall,
      :preempt_exempt_time,
    ].each do |p|
      [
        '1-00:00:00',
        '05:00:00',
        '00:05:00',
        '00:00:30',
      ].each do |v|
        it "allows #{v} for #{p}" do
          config[p] = v
          expect(resource[p]).to eq(v)
        end
      end
      default = defaults.key?(p) ? defaults[p] : :absent
      it "has default for #{p}" do
        expect(resource[p]).to eq(default)
      end

      [
        'foo',
        300,
        '300',
        '24:00:00',
        '00:60:00',
        '00:00:60',
      ].each do |v|
        it "does not allow #{v} for #{p}" do
          config[p] = v
          expect { resource }.to raise_error(%r{#{p}})
        end
      end
    end
  end

  describe 'integer properties' do
    [
      :grace_time,
      :grp_jobs,
      :grp_jobs_accrue,
      :grp_submit_jobs,
      :max_jobs_per_account,
      :max_jobs_per_user,
      :max_submit_jobs_per_account,
      :max_submit_jobs_per_user,
      :min_prio_threshold,
      :priority,
    ].each do |p|
      it "accepts a #{p} integer" do
        config[p] = 1
        expect(resource[p]).to eq('1')
      end

      it "accepts a #{p} string" do
        config[p] = '1'
        expect(resource[p]).to eq('1')
      end

      default = defaults.key?(p) ? defaults[p] : :absent
      it "has default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'float properties' do
    [
      :usage_factor,
      :usage_threshold,
    ].each do |p|
      it "accepts a #{p} as float" do
        config[p] = 1.0
        expect(resource[p]).to eq('1.000000')
      end

      it "accepts a #{p} as string" do
        config[p] = '1.0'
        expect(resource[p]).to eq('1.000000')
      end

      default = defaults.key?(p) ? defaults[p] : :absent
      it "has default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'array properties' do
    [
      :preempt,
    ].each do |p|
      it "accepts array for #{p}" do
        config[p] = ['foo', 'bar']
        expect(resource[p]).to eq(['foo', 'bar'])
      end

      default = defaults.key?(p) ? defaults[p] : [:absent]
      it "has default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'hash properties' do
    [
      :grp_tres_mins,
      :grp_tres_run_mins,
      :grp_tres,
      :max_tres_mins,
      :max_tres_per_account,
      :max_tres_per_job,
      :max_tres_per_node,
      :max_tres_per_user,
      :min_tres_per_job,
    ].each do |p|
      it "accepts hash for #{p}" do
        config[p] = { 'foo' => 'bar' }
        expect(resource[p]).to eq('foo' => 'bar')
      end

      default = defaults.key?(p) ? defaults[p] : :absent
      it "has default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'flags' do
    ['DenyOnLimit', 'EnforceUsageThreshold', 'NoReserve', 'PartitionMaxNodes',
     'PartitionMinNodes', 'OverPartQOS', 'PartitionTimeLimit', 'RequiresReservation', 'NoDecay', 'UsageFactorSafe',].each do |v|
      it "accepts #{v}" do
        config[:flags] = v
        expect(resource[:flags]).to eq([v])
      end
    end
    it 'allows values' do
      config[:flags] = ['DenyOnLimit', 'RequiresReservation']
      expect(resource[:flags]).to eq(['DenyOnLimit', 'RequiresReservation'])
    end
  end

  describe 'preempt_mode' do
    [
      :cluster,
      :cancel,
      :checkpoint,
      :requeue,
    ].each do |v|
      it "accepts #{v}" do
        config[:preempt_mode] = v
        expect(resource[:preempt_mode]).to eq(v)
      end
    end
    it 'has default' do
      expect(resource[:preempt_mode]).to eq(:cluster)
    end
  end

  it 'autorequires slurm_clusters' do
    cluster = Puppet::Type.type(:slurm_cluster).new(name: 'foo')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource cluster
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(cluster.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires slurm_qos preempt' do
    config[:preempt] = 'test'
    qos = Puppet::Type.type(:slurm_qos).new(name: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource qos
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(qos.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end
end
