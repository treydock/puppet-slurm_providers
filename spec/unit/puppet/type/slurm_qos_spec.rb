require 'spec_helper'

slurm_qos = Puppet::Type.type(:slurm_qos)

describe slurm_qos do
  before :each do
    @slurm_qos = slurm_qos.new(:name => 'foo')
  end

  it 'should have validproperties' do
    slurm_qos.validproperties.should match_array([
      :grp_cpus, :grp_jobs, :grp_nodes, :grp_submit_jobs,
      :max_cpus, :max_jobs, :max_nodes, :max_nodes_per_user,
      :priority, :ensure, :description, :max_wall
    ])
  end

  it 'should have :name be its namevar' do
    slurm_qos.key_attributes.should == [:name]
  end

  it 'should require a name' do
    expect {
      slurm_qos.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  describe :name do
    it 'should accept a name' do
      @slurm_qos[:name].should == 'foo'
    end
  end

  describe :description do
    it 'should default to name' do
      @slurm_qos[:description].should == 'foo'
    end

    it 'should accept a description' do
      @slurm_qos[:description] = 'Foo QOS'
      @slurm_qos[:description].should == 'foo qos'
    end
  end

  describe :max_wall do
    it "should have default value -1" do
      @slurm_qos[:max_wall].should == '-1'
    end

    it "should accept value 72:00:00" do
      @slurm_qos[:max_wall] = '72:00:00'
      @slurm_qos[:max_wall].should == '72:00:00'
    end

    it "should not accept value 72:00" do
      lambda { @slurm_qos[:max_wall] = '72:00' }.should raise_error(Puppet::Error)
    end
  end

  describe :priority do
    it "should have default value 0" do
      @slurm_qos[:priority].should == '0'
    end

    ['10',10,'1',1,'-1',-1].each do |i|
      it "should accept #{i.class} value of #{i}" do
        @slurm_qos[:priority] = i
        @slurm_qos[:priority].should == i.to_s
      end
    end

    it "should not accept a non-numeric value" do
      lambda { @slurm_qos[:priority] = 'foo' }.should raise_error(Puppet::Error)
    end
  end

  [
    :grp_cpus, :grp_jobs, :grp_nodes, :grp_submit_jobs,
    :max_cpus, :max_jobs, :max_nodes, :max_nodes_per_user
  ].each do |p|
    describe p do
      it "should have default value -1" do
        @slurm_qos[p].should == '-1'
      end

      ['10',10,'1',1,'-1',-1].each do |i|
        it "should accept #{i.class} value of #{i}" do
          @slurm_qos[p] = i
          @slurm_qos[p].should == i.to_s
        end
      end

      it "should not accept a non-numeric value" do
        lambda { @slurm_qos[p] = 'foo' }.should raise_error(Puppet::Error)
      end
    end
  end
end
