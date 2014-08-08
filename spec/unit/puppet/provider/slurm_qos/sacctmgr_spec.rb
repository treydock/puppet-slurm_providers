require 'spec_helper'

slurm_qos_provider = Puppet::Type.type(:slurm_qos).provider(:sacctmgr)

describe slurm_qos_provider do
  let(:resource) {
    Puppet::Type.type(:slurm_qos).new({
      :name => 'foo',
    })
  }
  let(:provider) { slurm_qos_provider }
  let(:instance) { provider.instances.first }

  let(:valid_properties) {[
    :description,
    :flags,
    :grp_cpus,
    :grp_jobs,
    :grp_nodes,
    :grp_submit_jobs,
    :max_cpus,
    :max_cpus_per_user,
    :max_jobs,
    :max_nodes,
    :max_nodes_per_user,
    :max_submit_jobs,
    :max_wall,
    :preempt,
    :preempt_mode,
    :priority,
    :usage_factor
  ].sort}
  let(:all_properties) { [:name, valid_properties].flatten }
  let(:sacctmgr_properties) { [:name, valid_properties].flatten }
  let(:format_fields) { sacctmgr_properties.map { |p| p.to_s.gsub('_', '') }.join(',') }

  let :instance_defaults do
    defaults = {}
    all_properties.collect do |p|
      case p
      when :name
        defaults[p] = 'foo'
      when :description
        defaults[p] = 'foo'
      when :flags
        defaults[p] = ['-1']
      when :preempt
        next
      when :preempt_mode
        defaults[p] = 'cluster'
      when :priority
        defaults[p] = '0'
      else
        defaults[p] = '-1'
      end
    end
    defaults
  end

  before :each do
    Puppet::Util.stubs(:which).with('sacctmgr').returns('/usr/bin/sacctmgr')
    provider.stubs(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'qos', 'format=name']).returns('foo')
    provider.stubs(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'qos', 'name=foo', "format=#{format_fields}"]).returns('foo||||||||||||||||0|')
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
      provider.stubs(:prefetch).with({'foo' => instance})
      instance.instance_variable_get(:@property_hash).should == {
        :provider => :sacctmgr,
        :ensure => :present,
        :name => 'foo',
      }.merge(instance_defaults)
    end
  end

  describe 'set_values' do
    it 'should return Array of values for sacctmgr' do
      resource.provider.set_values.should match_array([
        'description=foo', 'flags=-1', 'grpcpus=-1', 'grpjobs=-1', 'grpnodes=-1',
        'grpsubmitjobs=-1', 'maxcpus=-1', 'maxcpusperuser=-1', 'maxjobs=-1',
        'maxnodes=-1', 'maxnodesperuser=-1', 'maxsubmitjobs=-1', 'maxwall=-1', 'priority=0',
        'preemptmode=cluster', 'usagefactor=-1'
      ])
    end
  end

  describe 'self.get_qos_properties' do
    it 'should return a Hash properties' do
      provider.get_qos_properties('foo').should == {
        :provider => :sacctmgr,
        :ensure => :present,
        :name => 'foo',
      }.merge(instance_defaults)
    end
  end

  describe 'self.instances' do
    it 'should return an instance' do
      provider.stubs(:get_qos_properties).with('foo').returns({
        :provider => :sacctmgr,
        :ensure => :present,
      }.merge(instance_defaults))

      provider.instances.should == [instance]
    end
  end

  describe 'exists?' do
    it 'checks if qos exists' do
      instance.exists?.should be_truthy
    end
  end

  describe 'destroy' do
    it 'should set :ensure => :absent' do
      instance.destroy
      instance.instance_variable_get(:@property_hash)[:ensure].should == :absent
    end
  end

  describe 'create_qos' do
    it 'should create a qos using sacctmgr' do
      resource.provider.expects(:sacctmgr).with([
        '-i', 'create', 'qos', 'foo', resource.provider.set_values].flatten)
      resource.provider.create_qos
    end
  end

  describe 'modify_qos' do
    it 'should modify a qos using sacctmgr' do
      provider.expects(:sacctmgr).with([
        '-i', 'modify', 'qos', 'foo', 'set', resource.provider.set_values].flatten)
      resource.provider.modify_qos
    end
  end

  describe 'destroy_qos' do
    it 'should destroy a qos using sacctmgr' do
      provider.expects(:sacctmgr).with(['-i','delete','qos','name=foo'])
      resource.provider.destroy_qos
    end
  end

  describe 'set_qos' do
    context 'when ensure => present' do
      before :each do
        resource.provider.instance_variable_set(:@property_hash, {:ensure => :present, :name => nil})
      end

      it 'should call create_qos' do
        resource.provider.expects(:create_qos)
        resource.provider.set_qos
      end
    end

    context 'when ensure => absent' do
      before :each do
        resource.provider.instance_variable_set(:@property_hash, {:ensure => :absent, :name => 'foo'})
      end

      it 'should call destroy_qos' do
        resource.provider.expects(:destroy_qos)
        resource.provider.set_qos
      end
    end
  end

  describe 'flush' do
    it 'should call set_qos' do
      resource.provider.expects(:set_qos)
      resource.provider.flush
    end
  end
end
