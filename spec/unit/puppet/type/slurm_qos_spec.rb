require 'spec_helper'

slurm_qos = Puppet::Type.type(:slurm_qos)

describe slurm_qos do
  before :each do
    @slurm_qos = slurm_qos.new(:name => 'foo')
  end

  it 'should have validproperties' do
    slurm_qos.validproperties.should match_array([
      :ensure,
      :description,
      :flags,
      :grp_cpu_mins,
      :grp_cpu_run_mins,
      :grp_cpus,
      :grp_jobs,
      :grp_memory,
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

  describe :flags do
    it 'should default to ["-1"]' do
      @slurm_qos[:flags].should match_array(["-1"])
    end

    it 'should accept a sorted Array' do
      @slurm_qos[:flags] = ["A","B"]
      @slurm_qos[:flags].should == ["A","B"]
    end

    it 'should accept and sort an unsorted Array' do
      @slurm_qos = slurm_qos.new(:name => 'foo', :flags => ["D","C"])
      @slurm_qos[:flags].should == ["C","D"]
    end

    it "should return well formed string of arrays for is_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :flags => ["A","B"])
      expect(@slurm_qos.property(:flags).is_to_s(["A","B"])).to eq "A,B"
    end

    it "should handle absent for is_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :flags => :absent)
      expect(@slurm_qos.property(:flags).is_to_s(:absent)).to eq :absent
    end

    it "should return well formed string of arrays for should_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :flags => ["A","B"])
      expect(@slurm_qos.property(:flags).should_to_s(["A","B"])).to eq "A,B"
    end

    it "should handle absent for should_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :flags => :absent)
      expect(@slurm_qos.property(:flags).should_to_s(:absent)).to eq "absent"
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

  describe :preempt do
    it 'should default to ["''"]' do
      @slurm_qos[:preempt].should be_nil
    end

    it 'should accept a sorted Array' do
      @slurm_qos[:preempt] = ["hi","low"]
      @slurm_qos[:preempt].should == ["hi","low"]
    end

    it 'should accept and sort an unsorted Array' do
      @slurm_qos = slurm_qos.new(:name => 'foo', :preempt => ["low","hi"])
      @slurm_qos[:preempt].should == ["hi","low"]
    end

    it "should return well formed string of arrays for is_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :preempt => ["low","hi"])
      expect(@slurm_qos.property(:preempt).is_to_s(["low","hi"])).to eq "low,hi"
    end

    it "should handle absent for is_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :preempt => :absent)
      expect(@slurm_qos.property(:preempt).is_to_s(:absent)).to eq :absent
    end

    it "should return well formed string of arrays for should_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :preempt => ["low","hi"])
      expect(@slurm_qos.property(:preempt).should_to_s(["low","hi"])).to eq "low,hi"
    end

    it "should handle absent for should_to_s" do
      @slurm_qos = slurm_qos.new(:name => 'foo', :preempt => :absent)
      expect(@slurm_qos.property(:preempt).should_to_s(:absent)).to eq "absent"
    end
  end

  describe :preempt_mode do
    it "should have default value to 'cluster'" do
      @slurm_qos[:preempt_mode].should == :cluster
    end

    [
      'cluster','cancel','checkpoint', 'requeue'
    ].each do |v|
      it "should accept value '#{v}'" do
        @slurm_qos[:preempt_mode] = v
        @slurm_qos[:preempt_mode].should == v.to_sym
      end
    end

    it "should not accept value invalid value" do
      lambda { @slurm_qos[:preempt_mode] = 'foo' }.should raise_error(Puppet::Error)
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
    :grp_cpu_mins,
    :grp_cpu_run_mins,
    :grp_cpus,
    :grp_jobs,
    :grp_memory,
    :grp_nodes,
    :grp_submit_jobs,
    :max_cpus,
    :max_cpus_per_user,
    :max_jobs,
    :max_nodes,
    :max_nodes_per_user,
    :max_submit_jobs,
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

  describe :usage_factor do
    it "should have default value 1.000000" do
      @slurm_qos[:usage_factor].should == '1.000000'
    end

    [
      {:is => '10', :should => '10.000000'},
      {:is => 10, :should => '10.000000'},
      {:is => '1', :should => '1.000000'},
      {:is => 1, :should => '1.000000'},
      {:is => '0.5', :should => '0.500000'},
      {:is => 0.5, :should => '0.500000'},
      {:is => '0.75', :should => '0.750000'},
      {:is => 0.75, :should => '0.750000'},
    ].each do |i|
      it "should be #{i[:should]} when #{i[:is]} of type #{i[:is].class}" do
        @slurm_qos[:usage_factor] = i[:is]
        @slurm_qos[:usage_factor].should == i[:should]
      end
    end

    it "should not accept -1" do
      lambda { @slurm_qos[:usage_factor] = -1 }.should raise_error(Puppet::Error)
    end

    it "should not accept '-1'" do
      lambda { @slurm_qos[:usage_factor] = '-1' }.should raise_error(Puppet::Error)
    end

    it "should not accept a non-numeric value" do
      lambda { @slurm_qos[:usage_factor] = 'foo' }.should raise_error(Puppet::Error)
    end
  end

  describe 'autorequire slurm_cluster resources' do
    it 'should autorequire a slurm_cluster' do
      slurm_cluster = Puppet::Type.type(:slurm_cluster).new(:name => 'linux')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource @slurm_qos
      catalog.add_resource slurm_cluster
      rel = @slurm_qos.autorequire[0]
      rel.source.ref.should == slurm_cluster.ref
      rel.target.ref.should == @slurm_qos.ref
    end
  end

end
