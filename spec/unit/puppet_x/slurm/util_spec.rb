require 'spec_helper'
require 'puppet_x/slurm/util'

describe PuppetX::SLURM::Util do
  describe 'parse_datetime' do
    it 'accepts date only' do
      expect(described_class.parse_datetime('2019-12-01')).to eq(['2019', '12', '01', nil, nil, nil])
    end
    it 'accepts date and time with no seconds' do
      expect(described_class.parse_datetime('2019-12-01T05:00')).to eq(['2019', '12', '01', '05', '00', nil])
    end
    it 'accepts date and time with seconds' do
      expect(described_class.parse_datetime('2019-12-01T05:00:30')).to eq(['2019', '12', '01', '05', '00', '30'])
    end
    it 'returns nil for no match' do
      expect(described_class.parse_datetime('foobar')).to be_nil
    end
  end
end
