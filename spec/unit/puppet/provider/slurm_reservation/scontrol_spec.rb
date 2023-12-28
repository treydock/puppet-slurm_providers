# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:slurm_reservation).provider(:scontrol) do
  let(:resource) do
    Puppet::Type.type(:slurm_reservation).new(name: 'maint')
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:scontrol).with(['show', 'reservation', '--oneliner'], {}).and_return(my_fixture_read('show.out'))
      expect(described_class.instances.length).to eq(3)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:scontrol).with(['show', 'reservation', '--oneliner'], {}).and_return(my_fixture_read('show.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('root_1')
      expect(property_hash[:flags]).to eq(['MAINT', 'IGNORE_JOBS'])
    end
  end

  describe 'create' do
    it 'creates a qos' do
      expect(resource.provider).to receive(:scontrol).with(['create', 'reservation', 'reservation=maint'], {})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end

    it 'creates a qos with timzone' do
      resource[:timezone] = 'UTC'
      expect(resource.provider).to receive(:scontrol).with(['create', 'reservation', 'reservation=maint'], { 'TZ' => 'UTC' })
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end

    it 'handles errors' do
      allow(resource.provider).to receive(:scontrol).and_raise(Puppet::ExecutionFailure, 'error')
      expect { resource.provider.create }.to raise_error('error')
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).not_to eq(:present)
    end
  end

  describe 'flush' do
    it 'updates a qos' do
      expect(resource.provider).to receive(:scontrol).with(['update', 'reservation=maint', 'tres=cpu=1'], {})
      resource.provider.tres = { 'cpu' => 1 }
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'delets a qos' do
      expect(resource.provider).to receive(:scontrol).with(['delete', 'reservation=maint'], {})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flags_update' do
    it 'handles updates with removal' do
      current = ['daily', 'PURGE_COMP=00:05:00', 'replace_down']
      new_flags = ['PURGE_COMP=00:07:00', 'REPLACE_DOWN']
      expected = ['flags-=DAILY', 'flags=PURGE_COMP=00:07:00']
      ret = resource.provider.flags_update(current, new_flags)
      expect(ret).to eq(expected)
    end
  end
end
