
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
          sequence  # 0
            1       # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until: '0_0 execute')

        expect(F.to_s(ms)).to eq('(msg 0_0 execute from:0)')

        # test

        ms = @executor.step(ms.first) # <-- feed execute message to 0_0

        n = @executor.node('0_0')

        expect(n).not_to eq(nil)

        expect(ms.size).to eq(1)

        m = ms.first

        expect(m['point']).to eq('receive')
        expect(m['nid']).to eq('0')
        expect(m['from']).to eq('0_0')
        expect(m['sm']).to eq(2)

        ms = @executor.step(ms.first)

        n = @executor.node('0_0')

        expect(n).to eq(nil)
      end
    end

    describe '#receive' do

      it 'replies to its parent' do

        # preparation

        flon = %{
          sequence    # 0
            sequence  # 0_0 <-- our test point
              1       # 0_0_0
        }

        ms = @executor.launch(flon, until: '0_0 receive', archive: true)

        expect(F.to_s(ms)).to eq('(msg 0_0 receive from:0_0_0)')

        # test

        ms = @executor.step(ms.first) # <-- feed the receive to 0_0

        n = @executor.node('0_0')

        expect(n['nid']).to eq('0_0')
        expect(n['parent']).to eq('0')
        expect(n['heat0']).to eq('sequence')

        expect(ms.size).to eq(1)
        expect(ms[0]['point']).to eq('receive')
        expect(ms[0]['nid']).to eq('0')
        expect(ms[0]['from']).to eq('0_0')

        ms = @executor.step(ms.first)

        n = @executor.node('0_0')

        expect(n).to eq(nil)

        n = @executor.archive['0_0']

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_0 m:5)
          (status o pt:execute)
        }.ftrim)

        expect(ms.size).to eq(1)

        expect(ms[0]['point']).to eq('receive')
        expect(ms[0]['nid']).to eq(nil)
        expect(ms[0]['from']).to eq('0')
        expect(ms[0]['sm']).to eq(5)
      end
    end

    describe '#receive from non-child' do

      it 'is not rejected'
    end

    describe '#cancel' do

      it 'replies to its parent it if it has no children' do

        # preparation

        flon = %{
          sequence   # 0
            stall _  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until_after: '0_0 receive', archive: true)

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
          (status closed pt:cancel m:5)
          (status o pt:execute)
        }.ftrim)

        expect(ms.size).to eq(1)

        expect(ms.first['point']).to eq('receive')
        expect(ms.first['nid']).to eq('0')
        expect(ms.first['from']).to eq('0_0')
        expect(ms.first['sm']).to eq(5)

        ms = @executor.step(ms.first)

        n = @executor.archive['0_0']

        expect(
          F.to_s(n, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_0 m:6)
          (status closed pt:cancel m:5)
          (status o pt:execute)
        }.ftrim)
      end
    end

    describe '#kill' do

      it 'works' do

        # preparation

        flon = %{
          sequence   # 0
            stall _  # 0_0 <-- our test point
        }

        ms = @executor.launch(flon, until_after: '0_0 receive')

        expect(ms).to eq([])

        # test

        m = {
          'point' => 'cancel', 'flavour' => 'kill',
          'nid' => '0_0', 'exid' => @executor.exid }

        ms = @executor.step(m) # <-- feed cancel message to node 0_0

        expect(F.to_s(ms)).to eq('(msg 0 receive from:0_0)')
      end
    end
  end

  context 'status "closed"' do

    describe '#receive' do

      it 'works' do

        # preparation

        flon = %{
          sequence      # 0
            sequence    # 0_0 <-- our test point
              sequence  # 0_0_0
        }

        ms = @executor.launch(flon, until_after: '0_0_0 execute')

        expect(F.to_s(ms)).to eq('(msg 0_0 receive from:0_0_0)')

        n = @executor.node('0_0')

        ms0 = @executor.step({
          'point' => 'cancel', 'nid' => '0_0', 'from' => '0' });

        n = @executor.node('0_0')

        expect(n['status'].last['status']).to eq('closed')

        # test

        ms = @executor.step({
          'point' => 'receive', 'nid' => '0_0', 'from' => '0_0_0',
          'payload' => {}  });

        expect(ms.size).to eq(1)

        m = ms[0]

        expect(m['point']).to eq('receive')
        expect(m['nid']).to eq('0')
        expect(m['from']).to eq('0_0')
        expect(m['payload']).to eq({})
      end
    end

    describe '#cancel' do

      it 'works'
    end

    describe '#kill' do

      it 'works' do

        # preparation

        flon = %{
          sequence      # 0
            sequence    # 0_0 <-- our test point
              sequence  # 0_0_0
        }

        ms = @executor.launch(flon, until_after: '0_0_0 execute')
        exid = ms.first['exid']

        expect(F.to_s(ms)).to eq('(msg 0_0 receive from:0_0_0)')

        n = @executor.node('0_0')

        ms0 = @executor.step({
          'point' => 'cancel', 'exid' => exid, 'nid' => '0_0', 'from' => '0' });

        n = @executor.node('0_0')

        expect(n['status'].last['status']).to eq('closed')

        # test

        ms = @executor.step({
          'point' => 'cancel', 'flavour' => 'kill',
          'exid' => exid, 'nid' => '0_0', 'from' => '0' });

        expect(F.to_s(ms)).to eq(%{
          (msg 0 receive from:0_0)
          (msg 0_0_0 cancel from:0_0)
        }.ftrim)

        cx = @executor.clone
          # fun part, clone the executor to test 2 scenarii

        child_then_kill_ms = Flor.dup(ms0) + Flor.dup(ms)
        kill_then_child_ms = Flor.dup(ms) + Flor.dup(ms0)

        # scenario 0

        puts "  \\\\\\ child ms before kill ms" if @executor.conf['log_msg']

        ms = @executor.walk(child_then_kill_ms)

        expect(F.to_s(ms)).to eq('(msg  terminated from:0)')

        # scenario 1

        puts "  \\\\\\ kill ms before child ms" if @executor.conf['log_msg']

        ms = cx.walk(kill_then_child_ms)

        expect(F.to_s(ms)).to eq('(msg  terminated from:0)')
      end
    end

    describe '#receive from child' do

      it 'works'
    end

    describe '#cancel from child' do

      it 'works'
    end

    describe '#cancel from child' do

      it 'works'
    end
  end

  context 'status "closed" on-error' do

    describe '#receive' do

      it 'does not open the node' do

        # preparation

        flon = %q{
          sequence on_error: (def err \ stall _)
            push l 1
        }

        ms = @executor.launch(flon)

        expect(ms).to eq(nil)

        seq = @executor.node('0')

        expect(
          F.to_s(seq, :status)
        ).to eq(%{
          (status closed pt:failed fla:on-error fro:0_1_1 m:13)
          (status o pt:execute)
        }.ftrim)

        expect(seq['cnodes']).to eq(%w[ 0_0_1-1 ])

        # test

        ms = @executor.step({
          'point' => 'receive', 'nid' => '0', 'from' => '0_0_1-1',
          'payload' => {} })

        expect(F.to_s(ms)).to eq('(msg  receive from:0)')

        seq = @executor.node('0')

        expect(
          F.to_s(seq, :status)
        ).to eq(%{
          (status closed pt:failed fla:on-error fro:0_1_1 m:13)
          (status o pt:execute)
        }.ftrim)

        ms = @executor.step(ms.first)

        expect(F.to_s(ms)).to eq('(msg  terminated from:0)')

        seq = @executor.node('0')

        expect(
          F.to_s(seq, :status)
        ).to eq(%{
          (status ended pt:receive fro:0 m:23)
          (status closed pt:failed fla:on-error fro:0_1_1 m:13)
          (status o pt:execute)
        }.ftrim)
      end
    end
  end

  context 'status "ended"' do

    describe '#receive' do

      #it 'is rejected'
        # because the node is gone
    end

    describe '#cancel' do

      #it 'is rejected'
        # because the node is gone
    end

    describe '#kill' do

      #it 'is rejected'
        # because the node is gone
    end
  end

  context 'status )gone(' do

    describe '#receive' do

      it 'has no effect' do

        # preparation

        ms = @executor.launch('sequence \\ stall _', until: '0_0 execute')

        expect(F.to_s(ms)).to eq('(msg 0_0 execute from:0)')

        exid = ms.first['exid']

        # test

        ms = @executor.step({
          'point' => 'receive', 'nid' => '0_1', 'from' => '0', 'exid' => exid,
          'payload' => {} })

        expect(ms).to eq([])
      end
    end

    describe '#cancel' do

      it 'has no effect' do

        # preparation

        ms = @executor.launch('sequence \\ stall _', until: '0_0 execute')

        expect(F.to_s(ms)).to eq('(msg 0_0 execute from:0)')

        exid = ms.first['exid']

        # test

        ms = @executor.step({
          'point' => 'cancel', 'flavour' => 'cancel',
          'nid' => '0_1', 'from' => '0', 'exid' => exid,
          'payload' => {} })

        expect(ms).to eq([])
      end
    end

    describe '#kill' do

      it 'has no effect' do

        # preparation

        ms = @executor.launch('sequence \\ stall _', until: '0_0 execute')

        expect(F.to_s(ms)).to eq('(msg 0_0 execute from:0)')

        exid = ms.first['exid']

        # test

        ms = @executor.step({
          'point' => 'cancel', 'flavour' => 'kill',
          'nid' => '0_1', 'from' => '0', 'exid' => exid,
          'payload' => {} })

        expect(ms).to eq([])
      end
    end
  end
end

