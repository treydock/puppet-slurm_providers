require 'spec_helper'

describe Puppet::Type.type(:slurm_account) do
  let(:default_config) { { name: 'foo on test' } }
  let(:config) { default_config }
  let(:resource) { described_class.new(config) }

  it 'adds to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.not_to raise_error
  end

  it 'has a name' do
    expect(resource[:name]).to eq('foo on test')
    expect(resource[:account]).to eq('foo')
    expect(resource[:cluster]).to eq('test')
  end

  it 'handles colon composite name' do
    config[:name] = 'foo:test'
    expect(resource[:account]).to eq('foo')
    expect(resource[:cluster]).to eq('test')
  end

  defaults = {
    description: nil,
    organization: nil,
    default_qos: nil,
    parent_name: 'root',
    fairshare: '1',
    qos: nil,
    priority: nil,
  }

  describe 'basic properties' do
    [
      :description,
      :organization,
      :default_qos,
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

  describe 'time properties' do
    [
      :grp_wall,
      :max_wall_duration_per_job,
    ].each do |p|
      [
        '1-00:00:00',
        '05:00:00',
        '00:05:00',
        '00:00:30',
      ].each do |v|
        it "should allow #{v} for #{p}" do
          config[p] = v
          expect(resource[p]).to eq(v)
        end
      end
      default = defaults.key?(p) ? defaults[p] : :absent
      it "should have default for #{p}" do
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
        it "should not allow #{v} for #{p}" do
          config[p] = v
          expect { resource }.to raise_error(%r{#{p}})
        end
      end
    end
  end

  describe 'integer properties' do
    [
      :grp_jobs,
      :grp_jobs_accrue,
      :grp_submit_jobs,
      :max_jobs,
      :max_jobs_accrue,
      :max_submit_jobs,
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
      :qos,
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
      :max_tres_mins_per_job,
      :max_tres_per_job,
      :max_tres_per_node,
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

  describe 'cluster' do
    it 'requires cluster' do
      config[:name] = 'foo'
      expect { resource }.to raise_error(%r{cluster})
    end
  end

  describe 'root account' do
    it 'does not default with parent_name' do
      config[:name] = 'root on linux'
      expect(resource[:parent_name]).to be_nil
    end
  end

  context 'autorequires' do
    it 'autorequires slurm_clusters' do
      cluster = Puppet::Type.type(:slurm_cluster).new(name: 'test')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource resource
      catalog.add_resource cluster
      rel = resource.autorequire[0]
      expect(rel.source.ref).to eq(cluster.ref)
      expect(rel.target.ref).to eq(resource.ref)
    end
    it 'autorequires parent slurm_account' do
      parent = Puppet::Type.type(:slurm_account).new(name: 'bar on test')
      config[:parent_name] = 'bar'
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource resource
      catalog.add_resource parent
      rel = resource.autorequire[0]
      expect(rel.source.ref).to eq(parent.ref)
      expect(rel.target.ref).to eq(resource.ref)
    end
    it 'autorequires slurm_qos' do
      qos = Puppet::Type.type(:slurm_qos).new(name: 'test')
      config[:qos] = ['test']
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource resource
      catalog.add_resource qos
      rel = resource.autorequire[0]
      expect(rel.source.ref).to eq(qos.ref)
      expect(rel.target.ref).to eq(resource.ref)
    end
  end
end
