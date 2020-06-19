require 'spec_helper'

describe Puppet::Type.type(:slurm_account).provider(:sacctmgr) do
  # Variable and let should be merged with acceptance test file
  type_properties = [
    :cluster, :organization, :parent_name, :description, :default_qos, :fairshare, :grp_tres_mins, :grp_tres_run_mins, :grp_tres,
    :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs, :grp_wall, :max_tres_mins_per_job, :max_tres_per_job, :max_jobs, :max_jobs_accrue,
    :max_submit_jobs, :max_wall_duration_per_job, :priority, :qos_level
  ]
  format_string = 'account,' + type_properties.map { |p| p.to_s.delete('_') }.sort.join(',')

  let(:resource) do
    Puppet::Type.type(:slurm_account).new(name: 'test on linux')
  end
  let(:name) { 'test' }
  let(:defaults) do
    {
      cluster: 'linux',
      description: name,
      organization: name,
      parent_name: 'root',
      grace_time: '00:00:00',
      fairshare: '1',
    }
  end
  let(:properties) { type_properties }
  let(:value) do
    values = [name]
    properties.sort.each do |p|
      v = send(p)
      values << v
    end
    values.join('|')
  end

  type_properties.each do |p|
    let(p) do
      if defaults.key?(p)
        defaults[p]
      else
        ''
      end
    end
  end

  describe 'test' do
    let(:name) { 'test' }
    let(:grp_tres) { 'cpu=1' }

    it do
      expect(value).to eq('test|linux||test|1||||cpu=1||||||||||test|root||')
    end
  end

  describe 'type_properties' do
    it 'has type_properties' do
      expect(described_class.type_properties).to eq(properties.sort)
    end
  end

  describe 'type_params' do
    it 'has type_params' do
      expected_value = [:account]
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
        .with(['list', 'account', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'where', 'user=']).and_return(my_fixture_read('list.out'))
      expect(described_class.instances.length).to eq(5)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:sacctmgr) \
        .with(['list', 'account', "format=#{format_string}", '--noheader', '--parsable2', 'withassoc', 'where', 'user=']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('root on linux')
    end
  end

  describe 'create' do
    it 'creates a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'create', 'account', 'test', 'cluster=linux', 'description=test', 'fairshare=1', 'organization=test', 'parent=root'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'updates a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'modify', 'account', 'test', 'set', 'grptres=cpu=1'])
      resource.provider.grp_tres = { 'cpu' => 1 }
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'delets a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'account', 'test'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end
end
