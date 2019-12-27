require 'spec_helper'

describe Puppet::Type.type(:slurm_reservation) do
  let(:default_config) { { name: 'foo', start_time: 'now', duration: '01:00:00', node_cnt: 1, users: ['root'] } }
  let(:config) { default_config }
  let(:resource) { described_class.new(config) }
  let(:defaults) do
    {
      start_time: default_config[:start_time],
      duration: default_config[:duration],
      node_cnt: default_config[:node_cnt],
      users: default_config[:users],
    }
  end

  it 'adds to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.not_to raise_error
  end

  it 'has a name' do
    expect(resource[:name]).to eq('foo')
  end

  describe 'basic properties' do
    [
      :burst_buffer,
      :core_cnt,
      :node_cnt,
      :nodes,
      :partition_name,
      :features,
    ].each do |p|
      it "should accept a #{p}" do
        config[p] = 'foo'
        expect(resource[p]).to eq('foo')
      end
      it "should have default for #{p}" do
        default = defaults[p]
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
      it "should have default for #{p}" do
        default = defaults[p]
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
    ].each do |p|
      it "should accept a #{p} integer" do
        config[p] = 1
        expect(resource[p]).to eq('1')
      end
      it "should accept a #{p} string" do
        config[p] = '1'
        expect(resource[p]).to eq('1')
      end
      it "should have default for #{p}" do
        default = defaults[p]
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'array properties' do
    [
      :accounts,
      :users,
    ].each do |p|
      it "should accept array for #{p}" do
        config[p] = ['foo', 'bar']
        expect(resource[p]).to eq(['foo', 'bar'])
      end
      it "should have default for #{p}" do
        default = defaults[p]
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'hash properties' do
    [
      :licenses,
      :tres,
    ].each do |p|
      it "should accept hash for #{p}" do
        config[p] = { 'foo' => 'bar' }
        expect(resource[p]).to eq('foo' => 'bar')
      end
      it "should have default for #{p}" do
        default = defaults[p]
        expect(resource[p]).to eq(default)
      end
    end
  end

  describe 'start_time' do
    it 'munges time if absent' do
      config[:start_time] = '2019-01-01'
      expect(resource[:start_time]).to eq('2019-01-01T00:00:00')
    end
    it 'munges time if seconds absent' do
      config[:start_time] = '2019-01-01T05:00'
      expect(resource[:start_time]).to eq('2019-01-01T05:00:00')
    end
    it 'accepts full date time' do
      config[:start_time] = '2019-01-01T05:00:00'
      expect(resource[:start_time]).to eq('2019-01-01T05:00:00')
    end
    [
      'now',
      'NOW',
      'now + 5 hours',
      'NOW + 5 hours',
      'today',
      'tomorrow',
    ].each do |v|
      it "accepts value #{v}" do
        config[:start_time] = v
        expect(resource[:start_time]).to eq(v)
      end
    end
    it 'rejects invalid values' do
      config[:start_time] = '300'
      expect { resource }.to raise_error(%r{Invalid value for start_time})
    end
  end

  describe 'end_time' do
    it 'munges time if absent' do
      config[:end_time] = '2019-01-01'
      expect(resource[:end_time]).to eq('2019-01-01T00:00:00')
    end
    it 'munges time if seconds absent' do
      config[:end_time] = '2019-01-01T05:00'
      expect(resource[:end_time]).to eq('2019-01-01T05:00:00')
    end
    it 'accepts full date time' do
      config[:end_time] = '2019-01-01T05:00:00'
      expect(resource[:end_time]).to eq('2019-01-01T05:00:00')
    end
    [
      'now',
      'NOW',
      'now + 5 hours',
      'NOW + 5 hours',
      'today',
      'tomorrow',
    ].each do |v|
      it "accepts value #{v}" do
        config[:end_time] = v
        expect(resource[:end_time]).to eq(v)
      end
    end
    it 'rejects invalid values' do
      config[:end_time] = '300'
      expect { resource }.to raise_error(%r{Invalid value for end_time})
    end
  end

  describe 'duration' do
    [
      '01:00:05',
      '1-00:05:00',
      'UNLIMITED',
      'unlimited',
    ].each do |v|
      it "accepts a valid value of #{v}" do
        config[:duration] = v
        expect(resource[:duration]).to eq(v)
      end
    end

    it 'munges hours' do
      config[:duration] = '05:00'
      expect(resource[:duration]).to eq('00:05:00')
    end
    it 'munges minutes' do
      config[:duration] = 90
      expect(resource[:duration]).to eq('01:30:00')
    end
    it 'munges minutes from string' do
      config[:duration] = '90'
      expect(resource[:duration]).to eq('01:30:00')
    end
  end

  describe 'flags' do
    ['ANY_NODES', 'DAILY', 'FLEX', 'FIRST_CORES', 'IGNORE_JOBS', 'LICENSE_ONLY', 'MAINT', 'NO_HOLD_JOBS_AFTER',
     'OVERLAP', 'PART_NODES', 'PURGE_COMP', 'REPLACE', 'REPLACE_DOWN', 'STATIC_ALLOC', 'TIME_FLOAT', 'WEEKDAY', 'WEEKEND', 'WEEKLY'].each do |v|
      it "accepts #{v}" do
        config[:flags] = v
        expect(resource[:flags]).to eq([v])
      end
      it "accepts #{v.downcase}" do
        config[:flags] = v.downcase
        expect(resource[:flags]).to eq([v])
      end
    end
    it 'allows values' do
      config[:flags] = ['IGNORE_JOBS', 'MAINT']
      expect(resource[:flags]).to eq(['IGNORE_JOBS', 'MAINT'])
    end
  end

  describe 'validations' do
    it 'requires either end_time or duration' do
      config.delete(:end_time)
      config.delete(:duration)
      expect { resource }.to raise_error(%r{Must specify either end_time or duration})
    end
    it 'requires start_time' do
      config.delete(:start_time)
      expect { resource }.to raise_error(%r{Must specify start_time})
    end
    it 'requires LICENSE_ONLY when only licenses' do
      config.delete(:nodes)
      config.delete(:node_cnt)
      config[:licenses] = { 'foo' => '1' }
      config.delete(:flags)
      expect { resource }.to raise_error(%r{LICENSE_ONLY})
    end
    it 'requires users or accounts' do
      config.delete(:users)
      config.delete(:accounts)
      expect { resource }.to raise_error(%r{Must specify either accounts or users})
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
