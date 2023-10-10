# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:slurm_license).provider(:sacctmgr) do
  # Variable and let should be merged with acceptance test file
  type_params = [
    :name, :cluster, :server
  ]
  type_properties = [
    :type, :count, :description, :allowed, :server_type
  ]
  format_string = (type_params + type_properties).map { |p| p.to_s.delete('_') }.join(',')

  let(:resource) do
    Puppet::Type.type(:slurm_license).new(name: 'matlab@server for test', count: 100)
  end
  let(:name) { 'test' }
  let(:defaults) do
    {
      resource_name: name,
      server: 'server',
      cluster: 'test'
    }
  end
  let(:params) { type_params }
  let(:properties) { type_properties }
  let(:value) do
    values = [name]
    params.sort.each do |p|
      v = send(p)
      values << v
    end
    properties.sort.each do |p|
      v = send(p)
      values << v
    end
    values.join('|')
  end

  (type_params + type_properties).each do |p|
    let(p) do
      if defaults.key?(p)
        defaults[p]
      else
        ''
      end
    end
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'resource', "format=#{format_string}", '--noheader', '--parsable2', 'withclusters']).and_return(my_fixture_read('list.out'))
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'resource', "format=#{format_string}", '--noheader', '--parsable2']).and_return(my_fixture_read('list2.out'))
      expect(described_class.instances.length).to eq(5)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'resource', "format=#{format_string}", '--noheader', '--parsable2', 'withclusters']).and_return(my_fixture_read('list.out'))
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'resource', "format=#{format_string}", '--noheader', '--parsable2']).and_return(my_fixture_read('list2.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('comsol@server for linux')
    end
  end

  describe 'create' do
    it 'creates a license' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'create', 'resource', 'matlab', 'cluster=test', 'server=server', 'type=License', 'count=100', 'description=matlab'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'updates a license' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'modify', 'resource', 'where', 'name=matlab', 'server=server', 'cluster=test', 'set', 'count=200'])
      resource.provider.count = 200
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'delets a license' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'resource', 'where', 'name=matlab', 'server=server', 'cluster=test'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end
end
