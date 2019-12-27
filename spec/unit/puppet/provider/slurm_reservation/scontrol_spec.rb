require 'spec_helper'

describe Puppet::Type.type(:slurm_reservation).provider(:scontrol) do
  let(:resource) do
    Puppet::Type.type(:slurm_reservation).new(name: 'maint')
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:scontrol).with(['show', 'reservation', '--oneliner']).and_return(my_fixture_read('show.out'))
      expect(described_class.instances.length).to eq(2)
    end

    it 'creates instance with name' do
      allow(described_class).to receive(:scontrol).with(['show', 'reservation', '--oneliner']).and_return(my_fixture_read('show.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('root_1')
      expect(property_hash[:flags]).to eq(['MAINT', 'IGNORE_JOBS'])
    end
  end

  describe 'create' do
    it 'creates a qos' do
      expect(resource.provider).to receive(:scontrol).with(['create', 'reservation', 'reservation=maint'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'updates a qos' do
      expect(resource.provider).to receive(:scontrol).with(['update', 'reservation=maint', 'tres=cpu=1'])
      resource.provider.tres = { 'cpu' => 1 }
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'delets a qos' do
      expect(resource.provider).to receive(:scontrol).with(['delete', 'reservation=maint'])
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end
end