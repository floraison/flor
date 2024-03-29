
#
# specifying flor
#
# Mon Feb 22 16:39:36 JST 2021
#
# Tue Nov 16 15:02:57 JST 2021
#   And now in quarantine, in Higashi Kasai IlFiore...
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'on_receive' do

    it 'binds in the parent node' do

      @executor.launch(
        %q{
          sequence
            on_receive (def msg \ _)
            stall _
        })

      expect(
        @executor.execution['nodes']['0']['on_receive']
      ).to eq([
        [ [ '*' ],
          [ '_func',
            { 'nid' => '0_0_0',
              'tree' => [
                'def', [
                  [ '_att', [ [ 'msg', [], 3 ] ], 3 ], [ '_', [], 3 ] ], 3],
              'cnid' => '0',
              'fun' => 0,
              'on_receive' => true },
            3 ] ]
      ])

      m = @executor.journal
        .find { |m| m['point'] == 'receive' && m['nid'] == '0' }

      expect(m['from_on']).to eq('receive')
    end

    it 'is triggered on each receive' do

      r = @executor.launch(
        %q{
          set l []
          sequence
            #on_receive (def msg \ push l 'a')
            on_receive (def msg \ push l "f$(msg.from)")
            push l 0
            push l 1
            push l 2
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 'f0_1_1', 1, 'f0_1_2', 2, 'f0_1_3' ])
    end

    it 'is triggered on each receive (2)' do

      r = @executor.launch(
        %q{
          set l []
          set f.l []
          sequence
            #on_receive (def msg \ push l 'a'; push f.l 'fa')
            #on_receive
            #  def msg \ push l 'a'; push f.l 'fa'
            on_receive
              def msg
                push l 'a'
                push f.l 'fa'
            sequence
              push l 0
              push f.l 0
            sequence
              push l 1
              push f.l 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 'a', 1, 'a', ])
      expect(r['payload']['l']).to eq([ 0, 'fa', 1, 'fa', ])
    end

    it 'plays well with cursor' do

      r = @executor.launch(
        %q{
          set l []
          cursor
            #on_receive (def \ break _ if l[-1] == 1)
            #on_receive (def \ break _ if l.-1 == 1)
            on receive
              break _ if l.-1 == 1
            push l 0
            push l 1
            push l 2
          push l 'z'
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq([ 0, 1, 'z' ])
    end

    it 'hands msg and fcid' do

      r = @executor.launch(
        %q{
          set l []
          cursor
            on_receive (def msg, fcid \ push l [ msg.from, fcid ])
            push l 0
            push l 1
            push l 2
        })

      expect(r['point']
        ).to eq('terminated')
      expect(r['vars']['l']
        ).to eq([ 0, [ '0_1_1', 1 ], 1, [ '0_1_2', 2 ], 2, [ '0_1_3', 3 ] ])
    end
  end
end

