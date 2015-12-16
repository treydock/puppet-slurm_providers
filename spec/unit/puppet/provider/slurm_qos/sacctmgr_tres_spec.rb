require 'spec_helper'

describe 'Provider sacctmgr_tres' do
  let(:facts) {{ :slurm_version => '15.08.0' }}
  before do
    Facter.stubs(:value).with(:slurm_version).returns('15.08.0')
    Puppet::Util.stubs(:which).with('sacctmgr').returns('/usr/bin/sacctmgr')
    @type = Puppet::Type.type(:slurm_qos)
    @type.stubs(:defaultprovider).returns Puppet::Type.type(:slurm_qos).provider(:sacctmgr_tres)
    @resource = @type.new({:name => 'foo' })
    @provider = Puppet::Type.type(:slurm_qos).provider(:sacctmgr_tres)
    @provider.stubs(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'qos', 'format=name']).returns('foo')
    @provider.stubs(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'qos', 'name=foo', "format=#{@provider.format_fields}"]).returns('foo|||||||||||||||')
    @instance = @provider.instances.first
  end

  describe 'self.prefetch' do
    it 'should populate @property_hash' do
      @provider.instances
      @provider.stubs(:prefetch).with({'foo' => @instance})
      @instance.instance_variable_get(:@property_hash).should == {
        :provider => :sacctmgr_tres,
        :ensure => :present,
        :name => 'foo',
        :description => 'foo',
        :flags => ['-1'],
        :grp_jobs => '-1',
        :grp_submit_jobs => '-1',
        :max_jobs => '-1',
        :max_submit_jobs => '-1',
        :max_wall => '-1',
        :preempt => ["''"],
        :preempt_mode => 'cluster',
        :priority => '0',
        :usage_factor => '1.000000',
        :grp_tres_cpu => '-1',
        :grp_tres_energy => '-1',
        :grp_tres_mem => '-1',
        :grp_tres_node => '-1',
        :max_tres_per_job_cpu => '-1',
        :max_tres_per_job_energy => '-1',
        :max_tres_per_job_mem => '-1',
        :max_tres_per_job_node => '-1',
        :max_tres_per_user_cpu => '-1',
        :max_tres_per_user_energy => '-1',
        :max_tres_per_user_mem => '-1',
        :max_tres_per_user_node => '-1',
        :min_tres_per_job_cpu => '-1',
        :min_tres_per_job_energy => '-1',
        :min_tres_per_job_mem => '-1',
        :min_tres_per_job_node => '-1',
      }
    end
  end

  describe 'set_values' do
    it 'should return Array of values for sacctmgr' do
      @resource.provider.set_values.should match_array([
        'description=foo', 'flags=-1',
        'grpjobs=-1', 'grpsubmitjobs=-1', 'maxjobs=-1', 'maxsubmitjobs=-1', 'maxwall=-1',
        'preempt=\'\'', 'preemptmode=cluster', 'priority=0', 'usagefactor=1.000000',
        'grptres=cpu=-1,energy=-1,mem=-1,node=-1', 'maxtresperjob=cpu=-1,energy=-1,mem=-1,node=-1',
        'maxtresperuser=cpu=-1,energy=-1,mem=-1,node=-1', 'mintresperjob=cpu=1,energy=-1,mem=-1,node=-1',
      ])
    end
  end

  describe 'self.get_qos_properties' do
    it 'should return a Hash properties' do
      @provider.get_qos_properties('foo').should == {
        :provider => :sacctmgr_tres,
        :ensure => :present,
        :name => 'foo',
        :description => 'foo',
        :flags => ['-1'],
        :grp_jobs => '-1',
        :grp_submit_jobs => '-1',
        :max_jobs => '-1',
        :max_submit_jobs => '-1',
        :max_wall => '-1',
        :preempt => ["''"],
        :preempt_mode => 'cluster',
        :priority => '0',
        :usage_factor => '1.000000',
        :grp_tres_cpu => '-1',
        :grp_tres_energy => '-1',
        :grp_tres_mem => '-1',
        :grp_tres_node => '-1',
        :max_tres_per_job_cpu => '-1',
        :max_tres_per_job_energy => '-1',
        :max_tres_per_job_mem => '-1',
        :max_tres_per_job_node => '-1',
        :max_tres_per_user_cpu => '-1',
        :max_tres_per_user_energy => '-1',
        :max_tres_per_user_mem => '-1',
        :max_tres_per_user_node => '-1',
        :min_tres_per_job_cpu => '-1',
        :min_tres_per_job_energy => '-1',
        :min_tres_per_job_mem => '-1',
        :min_tres_per_job_node => '-1',
      }
    end
  end

  describe 'self.instances' do
    it 'should return an instance' do
      @provider.stubs(:get_qos_properties).with('foo').returns({
        :provider => :sacctmgr_tres,
        :ensure => :present,
        :description => 'foo',
        :flags => ['-1'],
        :grp_jobs => '-1',
        :grp_submit_jobs => '-1',
        :max_jobs => '-1',
        :max_submit_jobs => '-1',
        :max_wall => '-1',
        :preempt => ["''"],
        :preempt_mode => 'cluster',
        :priority => '0',
        :usage_factor => '1.000000',
        :grp_tres_cpu => '-1',
        :grp_tres_energy => '-1',
        :grp_tres_mem => '-1',
        :grp_tres_node => '-1',
        :max_tres_per_job_cpu => '-1',
        :max_tres_per_job_energy => '-1',
        :max_tres_per_job_mem => '-1',
        :max_tres_per_job_node => '-1',
        :max_tres_per_user_cpu => '-1',
        :max_tres_per_user_energy => '-1',
        :max_tres_per_user_mem => '-1',
        :max_tres_per_user_node => '-1',
        :min_tres_per_job_cpu => '-1',
        :min_tres_per_job_energy => '-1',
        :min_tres_per_job_mem => '-1',
        :min_tres_per_job_node => '-1',
      })
      @provider.instances.should == [@instance]
    end
  end

  describe 'exists?' do
    it 'checks if qos exists' do
      @instance.exists?.should be_truthy
    end
  end

  describe 'destroy' do
    it 'should set :ensure => :absent' do
      @instance.destroy
      @instance.instance_variable_get(:@property_hash)[:ensure].should == :absent
    end
  end

  describe 'create_qos' do
    it 'should create a qos using sacctmgr' do
      @resource.provider.expects(:sacctmgr).with([
        '-i', 'create', 'qos', 'foo', @resource.provider.set_values].flatten)
      @resource.provider.create_qos
    end
  end

  describe 'modify_qos' do
    it 'should modify a qos using sacctmgr' do
      @provider.expects(:sacctmgr).with([
        '-i', 'modify', 'qos', 'foo', 'set', @resource.provider.set_values].flatten)
      @resource.provider.modify_qos
    end
  end

  describe 'destroy_qos' do
    it 'should destroy a qos using sacctmgr' do
      @provider.expects(:sacctmgr).with(['-i','delete','qos','name=foo'])
      @resource.provider.destroy_qos
    end
  end

  describe 'set_qos' do
    context 'when ensure => present' do
      before :each do
        @resource.provider.instance_variable_set(:@property_hash, {:ensure => :present, :name => nil})
      end

      it 'should call create_qos' do
        @resource.provider.expects(:create_qos)
        @resource.provider.set_qos
      end
    end

    context 'when ensure => absent' do
      before :each do
        @resource.provider.instance_variable_set(:@property_hash, {:ensure => :absent, :name => 'foo'})
      end

      it 'should call destroy_qos' do
        @resource.provider.expects(:destroy_qos)
        @resource.provider.set_qos
      end
    end
  end

  describe 'flush' do
    it 'should call set_qos' do
      @resource.provider.expects(:set_qos)
      @resource.provider.flush
    end
  end
end
