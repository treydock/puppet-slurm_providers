require 'spec_helper'
require 'puppet/provider/sacctmgr'

describe Puppet::Provider::Sacctmgr do
  describe 'tres' do
    it 'produces supported tres' do
      allow(described_class).to receive(:sacctmgr).with(['show', 'tres', 'format=type,name,id', '--noheader', '--parsable2']).and_return(my_fixture_read('tres_list.out'))
      ret = described_class.tres
      expect(ret).to include('cpu')
      expect(ret).to include('fs/disk')
    end
  end

  describe 'parse_time' do
    it 'handles parsing time to seconds' do
      expect(described_class.parse_time('00:05:00')).to eq(300)
      expect(described_class.parse_time('05:00')).to eq(300)
      expect(described_class.parse_time('1-00:05:00')).to eq(86700)
      expect(described_class.parse_time('01:05:00')).to eq(3900)
      expect(described_class.parse_time('2-00:00:00')).to eq(172800)
      expect(described_class.parse_time('00:00:00')).to eq(0)
      expect(described_class.parse_time('00:00')).to eq(0)
    end
  end
end
