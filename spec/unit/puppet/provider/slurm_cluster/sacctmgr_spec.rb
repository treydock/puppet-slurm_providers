require 'spec_helper'

slurm_cluster_provider = Puppet::Type.type(:slurm_cluster).provider(:sacctmgr)

describe slurm_cluster_provider do
  let(:resource) {
    Puppet::Type.type(:slurm_cluster).new({
      :name => 'linux',
    })
  }
  let(:provider) { slurm_cluster_provider }
  let(:instance) { provider.instances.first }

  let(:valid_properties) {[]}
  let(:all_properties) { [:name] }
  let(:sacctmgr_properties) { [:cluster] }
  let(:format_fields) { 'cluster' }

  before :each do
    Puppet::Util.stubs(:which).with('sacctmgr').returns('/usr/bin/sacctmgr')
    provider.stubs(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'cluster', 'format=cluster']).returns('linux')
    provider.stubs(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'cluster', 'cluster=linux', 'format=cluster']).returns('linux')
  end

  describe 'self.valid_properties' do
    it 'should contain properties Array' do
      provider.valid_properties.should match_array(valid_properties)
    end
  end

  describe 'self.all_properties' do
    it 'should contain :name plus valid_properties' do
      provider.all_properties.should match_array(all_properties)
    end
  end

  describe 'self.sacctmgr_properties' do
    it 'should contain :name plus valid_properties' do
      provider.sacctmgr_properties.should match_array(sacctmgr_properties)
    end
  end

  describe 'self.format_fields' do
    it 'should create column names used for format' do
      provider.format_fields.should == format_fields
    end
  end

  describe 'self.prefetch' do
    it 'should populate @property_hash' do
      provider.instances
      provider.stubs(:prefetch).with({'linux' => instance})
      instance.instance_variable_get(:@property_hash).should == {
        :provider => :sacctmgr,
        :ensure => :present,
        :name => 'linux',
      }
    end
  end

  describe 'set_values' do
    it 'should return Array of values for sacctmgr' do
      resource.provider.set_values.should match_array([])
    end
  end

  describe 'self.get_cluster_properties' do
    it 'should return a Hash properties' do
      provider.expects(:all_properties).with().returns([:name])
      provider.get_cluster_properties('linux').should == {
        :provider => :sacctmgr,
        :ensure => :present,
        :name => 'linux',
      }
    end
  end

  describe 'self.instances' do
    it 'should return an instance' do
      provider.stubs(:get_cluster_properties).with('linux').returns({
        :provider => :sacctmgr,
        :ensure => :present,
        :name => 'linux',
      })

      provider.instances.should == [instance]
    end
  end

  describe 'exists?' do
    it 'checks if cluster exists' do
      instance.exists?.should be_truthy
    end
  end

  describe 'destroy' do
    it 'should set :ensure => :absent' do
      instance.destroy
      instance.instance_variable_get(:@property_hash)[:ensure].should == :absent
    end
  end

  describe 'create_cluster' do
    it 'should create a cluster using sacctmgr' do
      provider.expects(:sacctmgr).with(['-i','create','cluster','linux'])
      resource.provider.create_cluster
    end
  end

  describe 'modify_cluster' do
    it { resource.provider.should respond_to(:modify_cluster) }

    it 'should modify a cluster using sacctmgr' do
      skip("no parameters require use of modify")
      provider.expects(:sacctmgr).with(['-i','modify','cluster','linux','set', resource.provider.set_values])
      resource.provider.modify_cluster
    end
  end

  describe 'destroy_cluster' do
    it 'should destroy a cluster using sacctmgr' do
      provider.expects(:sacctmgr).with(['-i','delete','cluster','name=linux'])
      resource.provider.destroy_cluster
    end
  end

  describe 'set_cluster' do
    context 'when ensure => present' do
      before :each do
        resource.provider.instance_variable_set(:@property_hash, {:ensure => :present, :name => nil})
      end

      it 'should call create_cluster' do
        resource.provider.expects(:create_cluster)
        resource.provider.set_cluster
      end
    end

    context 'when ensure => absent' do
      before :each do
        resource.provider.instance_variable_set(:@property_hash, {:ensure => :absent, :name => 'foo'})
      end

      it 'should call destroy_cluster' do
        resource.provider.expects(:destroy_cluster)
        resource.provider.set_cluster
      end
    end
  end

  describe 'flush' do
    it 'should call set_cluster' do
      resource.provider.expects(:set_cluster)
      resource.provider.flush
    end
  end
end
