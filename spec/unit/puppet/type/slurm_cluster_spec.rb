require 'spec_helper'

describe 'Puppet::Type.type(:slurm_cluster)' do
  before :each do
    @type = Puppet::Type.type(:slurm_cluster)
    @slurm_cluster = @type.new(:name => 'foo')
  end

  it 'should have validproperties' do
    @type.validproperties.should match_array([:ensure])
  end

  it 'should have :name be its namevar' do
    @type.key_attributes.should == [:name]
  end

  it 'should require a name' do
    expect {
      @type.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  describe :name do
    it 'should accept a name' do
      @slurm_cluster[:name].should == 'foo'
    end
  end

end
