require 'spec_helper'

describe Puppet::Type.type(:slurm_cluster) do
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
    flags: nil,
  }

  describe 'basic properties' do
    [
      :federation,
      :flags,
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
      :features,
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

  describe 'fed_state' do
    [
      :active,
      :inactive,
      :drain,
      :drain_remove,
    ].each do |v|
      it "accepts #{v}" do
        config[:fed_state] = v
        expect(resource[:fed_state]).to eq(v)
      end
    end
    it 'has not default' do
      expect(resource[:fed_state]).to be_nil
    end
  end
end
