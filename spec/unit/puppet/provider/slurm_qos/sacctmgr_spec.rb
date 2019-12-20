require 'spec_helper'

describe Puppet::Type.type(:slurm_qos).provider(:sacctmgr) do
  let(:resource) do
    Puppet::Type.type(:slurm_qos).new(name: 'high')
  end
  let(:properties) do
    [
      :description, :flags, :grace_time, :grp_tres_mins, :grp_tres_run_mins, :grp_tres,
      :grp_jobs, :grp_jobs_accrue, :grp_submit_jobs, :grp_wall, :max_tres_mins, :max_tres_per_account,
      :max_tres_per_job, :max_tres_per_node, :max_tres_per_user, :max_jobs_per_account, :max_jobs_per_user,
      :max_submit_jobs_per_account, :max_submit_jobs_per_user, :max_wall, :min_prio_threshold, :min_tres_per_job,
      :preempt, :preempt_mode, :preempt_exempt_time, :priority, :usage_factor, :usage_threshold
    ]
  end
  let(:format_string) do
    'name,' + properties.map { |p| p.to_s.delete('_') }.sort.join(',')
  end

  describe 'type_properties' do
    it 'has type_properties' do
      expect(described_class.type_properties).to eq(properties.sort)
    end
  end

  describe 'type_params' do
    it 'has type_params' do
      expected_value = []
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
      allow(described_class).to receive(:sacctmgr).with(['list', 'qos', "format=#{format_string}", '--noheader', '--parsable2']).and_return(my_fixture_read('list.out'))
      expect(described_class.instances.length).to eq(3)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:sacctmgr).with(['list', 'qos', "format=#{format_string}", '--noheader', '--parsable2']).and_return(my_fixture_read('list.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('normal')
    end
  end

  describe 'create' do
    it 'creates a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'create', 'qos', 'high', 'description=high', 'gracetime=00:00:00', 'preemptmode=cluster', 'priority=0', 'usagefactor=1.000000'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'updates a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'modify', 'qos', 'high', 'set', 'grptres=cpu=1'])
      resource.provider.grp_tres = { 'cpu' => 1 }
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'delets a qos' do
      expect(resource.provider).to receive(:sacctmgr).with(['-i', 'delete', 'qos', 'high'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end
end
