# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:slurm_user).provider(:sacctmgr) do
  # Variable and let should be merged with acceptance test file
  type_params = [
    :user, :account, :cluster, :partition,
  ]
  type_properties = [
    :admin_level, :default_account, :default_qos, :fairshare, :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs,
    :grp_tres, :grp_tres_mins, :grp_tres_run_mins,
    :grp_wall, :max_jobs, :max_jobs_accrue, :max_submit_jobs, :max_tres_mins_per_job, :max_tres_per_job, :max_tres_per_node,
    :max_wall_duration_per_job, :priority, :qos,
  ]
  format_string = (type_params + type_properties).map { |p| p.to_s.delete('_') }.join(',')

  let(:resource) do
    Puppet::Type.type(:slurm_user).new(name: 'foo under test on linux')
  end
  let(:name) { 'foo' }
  let(:defaults) do
    {
      cluster: 'linux',
      account: 'test',
      admin_level: 'None',
      fairshare: '1',
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

  describe 'test' do
    let(:name) { 'foo' }
    let(:grp_tres) { 'cpu=1' }

    it do
      expect(value).to eq('foo|test|linux|||None|||1||||cpu=1||||||||||||')
    end
  end

  describe 'type_properties' do
    it 'has type_properties' do
      expect(described_class.type_properties).to eq(properties.sort)
    end
  end

  describe 'type_params' do
    it 'has type_params' do
      expected_value = [:account, :cluster, :partition, :user]
      expect(described_class.type_params).to eq(expected_value)
    end
  end

  describe 'format_fields' do
    it 'has format_fields' do
      expect(described_class.format_fields).to eq(format_string)
    end
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc']).and_return(my_fixture_read('list.out'))
      expect(described_class.instances.length).to eq(3)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('root under root on linux')
    end
  end

  describe 'create' do
    it 'creates a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'create', 'user', 'foo', 'account=test', 'cluster=linux', 'adminlevel=None', 'fairshare=1'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'updates a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'modify', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'set', 'grptres=cpu=1'])
      resource.provider.grp_tres = { 'cpu' => 1 }
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'delets a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end
end
