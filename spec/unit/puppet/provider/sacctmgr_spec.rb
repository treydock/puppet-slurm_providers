require 'spec_helper'
require 'puppet/provider/sacctmgr'

describe Puppet::Provider::Sacctmgr do
  describe 'self.name_attribute' do
    it 'should be :name' do
      Puppet::Provider::Sacctmgr.name_attribute.should == :name
    end
  end

  context 'Slurm_qos' do
    [
      '14.03.10',
    ].each do |ver|
      context "slurm_version => #{ver}" do
        before(:each) do
          Facter.stubs(:value).with(:slurm_version).returns(ver)
        end

        if ver =~ /^14/
          let(:provider) { Puppet::Type.type(:slurm_qos).provider(:sacctmgr) }
        end

        describe 'self.sacctmgr_name_attribute' do
          it 'should be :name' do
            provider.sacctmgr_name_attribute.should == :name
          end
        end

        describe 'self.sacctmgr_show' do
          it 'should provide base sacctmgr show arguments' do
            provider.sacctmgr_show.should match_array([
              '--noheader', '--parsable2', 'show', 'qos'
            ])
          end
        end

        describe 'self.get_names' do
          it 'should list qos names' do
            provider.expects(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'qos', 'format=name']).returns("foo\nbar")
            provider.get_names.should match_array(['foo','bar'])
          end
        end
      end
    end
  end

  context 'Slurm_cluster' do
    let(:provider) { Puppet::Type.type(:slurm_cluster).provider(:sacctmgr) }

    describe 'self.sacctmgr_name_attribute' do
      it 'should be :cluster' do
        provider.sacctmgr_name_attribute.should == :cluster
      end
    end

    describe 'self.sacctmgr_show' do
      it 'should provide base sacctmgr show arguments' do
        provider.sacctmgr_show.should match_array([
          '--noheader', '--parsable2', 'show', 'cluster'
        ])
      end
    end

    describe 'self.get_names' do
      it 'should list cluster names' do
        provider.expects(:sacctmgr).with(['--noheader', '--parsable2', 'show', 'cluster', 'format=cluster']).returns("foo\nbar")
        provider.get_names.should match_array(['foo','bar'])
      end
    end
  end

end
