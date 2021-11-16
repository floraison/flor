
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
            on_receive (def msg \ push l 'a')
            push l 0
            push l 1
            push l 2
        })

pp r
      expect(r['point']).to eq('terminated')
      #expect(r['vars']['l']).to eq([ 'a', 0, 'a', 1, 'a', 2, 'a' ])
      expect(r['vars']['l']).to eq([ 0, 'a', 1, 'a', 2, 'a' ])
    end
  end
end

