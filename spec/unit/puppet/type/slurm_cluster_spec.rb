require 'spec_helper'

slurm_cluster = Puppet::Type.type(:slurm_cluster)

describe slurm_cluster do
  before :each do
    @slurm_cluster = slurm_cluster.new(:name => 'foo')
  end

  it 'should have validproperties' do
    slurm_cluster.validproperties.should match_array([:ensure])
  end

  it 'should have :name be its namevar' do
    slurm_cluster.key_attributes.should == [:name]
  end

  it 'should require a name' do
    expect {
      slurm_cluster.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  describe :name do
    it 'should accept a name' do
      @slurm_cluster[:name].should == 'foo'
    end
  end

  describe 'autorequire slurm_qos resources' do
    it 'should autorequire a slurm_qos' do
      slurm_qos = Puppet::Type.type(:slurm_qos).new(:name => 'bar')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource @slurm_cluster
      catalog.add_resource slurm_qos
      rel = @slurm_cluster.autorequire[0]
      rel.source.ref.should == slurm_qos.ref
      rel.target.ref.should == @slurm_cluster.ref
    end
  end
end
