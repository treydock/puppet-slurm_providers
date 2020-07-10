require 'spec_helper'

describe Puppet::Type.type(:slurm_license) do
  let(:default_config) { { name: 'matlab@server', count: '100' } }
  let(:config) { default_config }
  let(:resource) { described_class.new(config) }

  it 'adds to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.not_to raise_error
  end

  it 'has a name' do
    config[:name] = 'matlab@server for test'
    config.delete(:count)
    expect(resource[:name]).to eq('matlab@server for test')
    expect(resource[:resource_name]).to eq('matlab')
    expect(resource[:server]).to eq('server')
    expect(resource[:cluster]).to eq('test')
  end

  it 'has a name without cluster' do
    config[:name] = 'matlab@server'
    expect(resource[:name]).to eq('matlab@server')
    expect(resource[:resource_name]).to eq('matlab')
    expect(resource[:server]).to eq('server')
    expect(resource[:cluster]).to be_nil
  end

  defaults = {
    count: '100',
    description: 'matlab',
    server_type: :absent,
    percent_allowed: nil,
  }

  describe 'basic properties' do
    [
      :description,
      :server_type,
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
      :count,
      :percent_allowed,
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

  describe 'validations' do
    it 'requires server' do
      config[:name] = 'test'
      config[:resource_name] = 'matlab'
      config[:cluster] = 'test'
      config.delete(:server)
      expect { resource.pre_run_check }.to raise_error(%r{server})
    end
    it 'requires cluster or count' do
      config.delete(:count)
      config.delete(:cluster)
      expect { resource.pre_run_check }.to raise_error(%r{define at least cluster with percent_allowed or count})
    end
    it 'requires percent_allocated with cluster' do
      config[:cluster] = 'test'
      config.delete(:percent_allowed)
      expect { resource.pre_run_check }.to raise_error(%r{percent_allowed is required})
    end
    it 'does not allow count with cluster' do
      config[:cluster] = 'test'
      config[:percent_allowed] = 100
      config[:count] = 100
      expect { resource.pre_run_check }.to raise_error(%r{Can not use count with cluster})
    end
    it 'does not allow server_type with cluster' do
      config.delete(:count)
      config[:cluster] = 'test'
      config[:percent_allowed] = 100
      config[:server_type] = 'flexlm'
      expect { resource.pre_run_check }.to raise_error(%r{Can not use server_type with cluster})
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
    it 'requires slurm_license with count' do
      config[:name] = 'matlab@server for test'
      config.delete(:count)
      config[:percent_allowed] = 100
      license = Puppet::Type.type(:slurm_license).new(name: 'matlab@server', count: 100)
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource resource
      catalog.add_resource license
      rel = resource.autorequire[0]
      expect(rel.source.ref).to eq(license.ref)
      expect(rel.target.ref).to eq(resource.ref)
    end
  end
end
