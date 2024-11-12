# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:slurm_user).provider(:sacctmgr) do
  # Variable and let should be merged with acceptance test file
  type_params = [
    :user, :account, :cluster, :partition,
  ]
  type_properties = [
    :admin_level, :coordinator, :default_account, :default_qos, :fairshare, :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs,
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
      expect(value).to eq('foo|test|linux|||None||||1||||cpu=1||||||||||||')
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
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'withcoord']).and_return(my_fixture_read('list.out'))
      expect(described_class.instances.length).to eq(7)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'withcoord']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('root under root on linux')
    end

    it 'creates instance with name and partition' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'withcoord']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[3].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('testuser under test2 on test partition testpart')
    end

    it 'creates instance without coordinator role' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'withcoord']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[3].instance_variable_get('@property_hash')
      expect(property_hash[:coordinator]).to eq(:false)
    end

    it 'creates instance with coordinator role' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'withcoord']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[4].instance_variable_get('@property_hash')
      expect(property_hash[:coordinator]).to eq(:true)
    end
    
    it 'creates instance with multiple coordinator roles' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'user', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'withcoord']).and_return(my_fixture_read('list.out'))
      expect(described_class.instances[5].instance_variable_get('@property_hash')[:coordinator]).to eq(:true)
      expect(described_class.instances[6].instance_variable_get('@property_hash')[:coordinator]).to eq(:true)
    end
  end

  describe 'create' do
    it 'creates a user' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'create', 'user', 'foo', 'account=test', 'cluster=linux', 'adminlevel=None', 'fairshare=1'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end

    context 'with a partition' do
      it 'creates a user' do
        resource[:partition] = 'testpart'
        expect(resource.provider).to receive(:sacctmgr).with(['-i', 'create', 'user', 'foo', 'account=test', 'cluster=linux', 'partition=testpart', 'adminlevel=None', 'fairshare=1'])
        resource.provider.create
        property_hash = resource.provider.instance_variable_get('@property_hash')
        expect(property_hash[:ensure]).to eq(:present)
      end
    end
  end

  describe 'flush' do
    it 'updates a user' do
      expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'modify', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'partition=', 'set', 'grptres=cpu=1'])
      resource.provider.grp_tres = { 'cpu' => 1 }
      resource.provider.flush
    end

    context 'with coordinator role' do
      it 'updates a user to add coordinator role' do
        expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'modify', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'partition=', 'set', 'grptres=cpu=1'])
        expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'add', 'coordinator', 'account=test', 'user=foo'])
        resource.provider.grp_tres = { 'cpu' => 1 }
        resource.provider.coordinator = :true
        resource.provider.flush
      end
      
      it 'updates a user to remove coordinator role' do
        resource[:coordinator] = :true
        expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'modify', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'partition=', 'set', 'grptres=cpu=1'])
        expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'remove', 'coordinator', 'account=test', 'user=foo'])
        resource.provider.grp_tres = { 'cpu' => 1 }
        resource.provider.coordinator = :false
        resource.provider.flush
      end
    end

    context 'with a partition' do
      it 'updates a user' do
        resource[:partition] = 'testpart'
        expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'modify', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'partition=testpart', 'set', 'grptres=cpu=1'])
        resource.provider.grp_tres = { 'cpu' => 1 }
        resource.provider.flush
      end
      
      context 'with coordinator role' do
        it 'updates a user to add coordinator role' do
          resource[:partition] = 'testpart'
          expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'modify', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'partition=testpart', 'set', 'grptres=cpu=1'])
          expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'add', 'coordinator', 'account=test', 'user=foo'])
          resource.provider.grp_tres = { 'cpu' => 1 }
          resource.provider.coordinator = :true
          resource.provider.flush
        end
        
        it 'updates a user to remove coordinator role' do
          resource[:partition] = 'testpart'
          resource[:coordinator] = :true
          expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'modify', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'partition=testpart', 'set', 'grptres=cpu=1'])
          expect(resource.provider).to receive(:sacctmgr).once.ordered.with(['-i', 'remove', 'coordinator', 'account=test', 'user=foo'])
          resource.provider.grp_tres = { 'cpu' => 1 }
          resource.provider.coordinator = :false
          resource.provider.flush
        end
      end
    end
  end

  describe 'destroy' do
    it 'deletes a user' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end

    context 'with a partition' do
      it 'deletes a user' do
        resource[:partition] = 'testpart'
        expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'user', 'where', 'name=foo', 'account=test', 'cluster=linux', 'partition=testpart'])
        resource.provider.destroy
        property_hash = resource.provider.instance_variable_get('@property_hash')
        expect(property_hash).to eq({})
      end
    end

    context 'when the user is root' do
      it 'will warn and not delete without a partition' do
        resource[:user] = 'root'
        expect(Puppet).to receive(:warning).with('Slurm_user[foo under test on linux] Not permitted to delete root user. Must define root user or remove cluster')
        resource.provider.destroy
      end

      it 'deletes from the partition' do
        resource[:user] = 'root'
        resource[:partition] = 'testpart'
        expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'user', 'where', 'name=root', 'account=test', 'cluster=linux', 'partition=testpart'])
        resource.provider.destroy
      end
    end
  end
end
