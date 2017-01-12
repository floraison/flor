
#
# specifying flor
#
# Tue Jan 10 10:57:43 JST 2017
#

require 'spec_helper'


describe Flor::Procedure do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '#execute' do

    it 'replies to its parent if it has no children' do

      # preparation

      flon = %{
        sequence    # 0
          sequence  # 0_0 <-- our test point
      }

      ms = @executor.launch(flon, until: '0_0 execute')

      expect(summarize(ms)).to eq('(msg 0_0 execute from:0)')

      # test

      ms = @executor.step(ms.first)
      m = ms.first

      n = @executor.node('0_0')

      expect(n['nid']).to eq('0_0')
      expect(n['parent']).to eq('0')
      expect(n['heat0']).to eq('sequence')
      expect(n['status'][0, 4]).to eq([ nil, nil, nil, nil ])

      expect(ms.size).to eq(1)

      expect(m['point']).to eq('receive')
      expect(m['nid']).to eq('0')
      expect(m['from']).to eq('0_0')
      expect(m['sm']).to eq(2)
    end
  end

  describe '#receive' do
  end

  describe '#cancel' do

    it 'replies to its parent it if has no children' do

      # preparation

      flon = %{
        sequence   # 0
          stall _  # 0_0 <-- our test point
      }

      ms = @executor.launch(flon, until_after: '0_0 receive')

      expect(ms).to eq([])

      # test

      # TODO
    end
  end
end

