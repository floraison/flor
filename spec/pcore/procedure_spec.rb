
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

  context 'status open' do

    describe '#execute' do

      it 'replies to its parent if it has no children' do

        # preparation

        flon = %{
          sequence    # 0
            sequence  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until: '0_0 execute')

        expect(F.to_s(ms)).to eq('(msg 0_0 execute from:0)')

        # test

        ms = @executor.step(ms.first) # <-- feed execute message to 0_0
        m = ms.first

        n = @executor.node('0_0')

        expect(n['nid']).to eq('0_0')
        expect(n['parent']).to eq('0')
        expect(n['heat0']).to eq('sequence')

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:execute fro:0 m:2)
          (status o pt:execute)
        }.ftrim)

        expect(ms.size).to eq(1)

        expect(m['point']).to eq('receive')
        expect(m['nid']).to eq('0')
        expect(m['from']).to eq('0_0')
        expect(m['sm']).to eq(2)
      end
    end

    describe '#receive' do

      it 'replies to its parent' do

        # preparation

        flon = %{
          sequence      # 0
            sequence _  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until: '0_0 receive')

        expect(F.to_s(ms)).to eq('(msg 0_0 receive from:0_0_0)')

        # test

        ms = @executor.step(ms.first) # <-- feed the receive to 0_0

        n = @executor.node('0_0')

        expect(n['nid']).to eq('0_0')
        expect(n['parent']).to eq('0')
        expect(n['heat0']).to eq('sequence')

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_0_0 m:4)
          (status o pt:execute)
        }.ftrim)

        expect(ms.size).to eq(1)

        expect(ms.first['point']).to eq('receive')
        expect(ms.first['nid']).to eq('0')
        expect(ms.first['from']).to eq('0_0')
        expect(ms.first['sm']).to eq(4)
      end
    end

    describe '#cancel' do

      it 'replies to its parent it if it has no children' do

        # preparation

        flon = %{
          sequence   # 0
            stall _  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until_after: '0_0 receive')

        expect(ms).to eq([])

        # test

        m = { 'point' => 'cancel', 'nid' => '0_0', 'exid' => @executor.exid }

        ms = @executor.step(m) # <-- feed cancel message to node 0_0

        n = @executor.node('0_0')

        expect(n['nid']).to eq('0_0')
        expect(n['parent']).to eq('0')
        expect(n['heat0']).to eq('stall')

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:cancel m:5)
          (status o pt:execute)
        }.ftrim)

        expect(ms.size).to eq(1)

        expect(ms.first['point']).to eq('receive')
        expect(ms.first['nid']).to eq('0')
        expect(ms.first['from']).to eq('0_0')
        expect(ms.first['sm']).to eq(5)
      end
    end

    describe '#kill' do

      it 'works'
    end
  end

  context 'status "closed"' do

    describe '#receive' do

      it 'works'
    end

    describe '#cancel' do

      it 'works'
    end

    describe '#kill' do

      it 'works'
    end
  end

  context 'status "ended"' do

    describe '#receive' do

      it 'is rejected' do

        # preparation

        flon = %{
          sequence    # 0
            sequence  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until: '0 receive')

        expect(F.to_s(ms)).to eq('(msg 0 receive from:0_0)')

        # test

        n = @executor.node('0_0')

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:execute fro:0 m:2)
          (status o pt:execute)
        }.ftrim)

        m = {
          'point' => 'receive', 'exid' => n['exid'],
          'nid' => '0_0', 'from' => '0_0_0',
          'payload' => {} }

        ms = @executor.step(m) # <-- feed receive message to ended 0_0

        expect(ms).to eq([])
      end
    end

    describe '#cancel' do

      it 'is rejected' do

        # preparation

        flon = %{
          sequence    # 0
            sequence  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until: '0 receive')

        expect(F.to_s(ms)).to eq('(msg 0 receive from:0_0)')

        # test

        n = @executor.node('0_0')

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:execute fro:0 m:2)
          (status o pt:execute)
        }.ftrim)

        m = {
          'point' => 'cancel', 'exid' => n['exid'],
          'nid' => '0_0', 'from' => '0',
          'payload' => {} }

        ms = @executor.step(m) # <-- feed receive message to ended 0_0

        expect(ms).to eq([])
      end
    end

    describe '#kill' do

      it 'is rejected' do

        # preparation

        flon = %{
          sequence    # 0
            sequence  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until: '0 receive')

        expect(F.to_s(ms)).to eq('(msg 0 receive from:0_0)')

        # test

        n = @executor.node('0_0')

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:execute fro:0 m:2)
          (status o pt:execute)
        }.ftrim)

        m = {
          'point' => 'cancel', 'flavour' => 'kill', 'exid' => n['exid'],
          'nid' => '0_0', 'from' => '0',
          'payload' => {} }

        ms = @executor.step(m) # <-- feed receive message to ended 0_0

        expect(ms).to eq([])
      end
    end
  end
end

