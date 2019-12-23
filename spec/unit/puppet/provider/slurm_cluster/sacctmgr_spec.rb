require 'spec_helper'

describe Puppet::Type.type(:slurm_cluster).provider(:sacctmgr) do
  let(:resource) do
    Puppet::Type.type(:slurm_cluster).new(name: 'linux')
  end

  describe 'type_properties' do
    it 'has type_properties' do
      expected_value = [:features, :federation, :fed_state]
      expect(described_class.type_properties).to eq(expected_value.sort)
    end
  end

  describe 'type_params' do
    it 'has type_params' do
      expected_value = [:flags]
      expect(described_class.type_params).to eq(expected_value)
    end
  end

  describe 'format_fields' do
    it 'has format_fields' do
      expected_value = 'cluster,flags,features,fedstate,federation'
      expect(described_class.format_fields).to eq(expected_value)
    end
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:sacctmgr).with(['list', 'cluster', 'format=cluster,flags,features,fedstate,federation', '--noheader', '--parsable2']).and_return(my_fixture_read('list.out'))
      expect(described_class.instances.length).to eq(2)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:sacctmgr).with(['list', 'cluster', 'format=cluster,flags,features,fedstate,federation', '--noheader', '--parsable2']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('test1')
    end
  end

  describe 'create' do
    it 'creates a cluster' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'create', 'cluster', 'linux'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'updates a cluster' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'modify', 'cluster', 'linux', 'set', 'federation=foo'])
      resource.provider.federation = 'foo'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'delets a cluster' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'cluster', 'linux'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end
end
