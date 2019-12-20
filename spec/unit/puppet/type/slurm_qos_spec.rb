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
    grace_time: '00:00:00',
    usage_factor: '1.000000',
  }

  describe 'basic properties' do
    [
      :description,
      :grace_time,
      :grp_wall,
      :max_wall,
      :preempt_exempt_time,
    ].each do |p|
      it "should accept a #{p}" do
        config[p] = 'foo'
        expect(resource[p]).to eq('foo')
      end
      default = defaults.key?(p) ? defaults[p] : :absent
      it "should have default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'integer properties' do
    [
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
      it "should accept a #{p} integer" do
        config[p] = 1
        expect(resource[p]).to eq('1')
      end
      it "should accept a #{p} string" do
        config[p] = '1'
        expect(resource[p]).to eq('1')
      end
      default = defaults.key?(p) ? defaults[p] : :absent
      it "should have default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'float properties' do
    [
      :usage_factor,
      :usage_threshold,
    ].each do |p|
      it "should accept a #{p} as float" do
        config[p] = 1.0
        expect(resource[p]).to eq('1.000000')
      end
      it "should accept a #{p} as string" do
        config[p] = '1.0'
        expect(resource[p]).to eq('1.000000')
      end
      default = defaults.key?(p) ? defaults[p] : :absent
      it "should have default for #{p}" do
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'array properties' do
    [
      :flags,
      :preempt,
    ].each do |p|
      it "should accept array for #{p}" do
        config[p] = ['foo', 'bar']
        expect(resource[p]).to eq(['foo', 'bar'])
      end
      default = defaults.key?(p) ? defaults[p] : [:absent]
      it "should have default for #{p}" do
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
      it "should accept hash for #{p}" do
        config[p] = { 'foo' => 'bar' }
        expect(resource[p]).to eq('foo' => 'bar')
      end
      default = defaults.key?(p) ? defaults[p] : :absent
      it "should have default for #{p}" do
        expect(resource[p]).to eq(default)
      end
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
end
