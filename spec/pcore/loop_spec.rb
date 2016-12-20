
#
# specifying flor
#
# Mon Dec 19 13:25:20 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'loop' do

    it 'loops' do

      flon = %{
        loop
          push f.l "$(nid)"
          break _ if "$(nid)" == "0_1_0_0-2"
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_0_1 0_0_1-1 0_0_1-2 ])
    end

    it 'understands "continue"' do

      flon = %{
        loop
          continue _ if "$(nid)" == "0_0_0_0-1"
          push f.l "$(nid)"
          break _ if "$(nid)" == "0_2_0_0-2"
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_1_1 0_1_1-2 ])
    end

    it 'goes {nid}-n for the subsequent cycles' do

      flon = %{
        loop
          break _ if "$(nid)" == "0_0_0_0-3"
      }

      r = @executor.launch(flon, journal: true)

      expect(
        @executor.journal
          .collect { |m| m['nid'] }
          .compact
          .uniq
          .join("\n")
      ).to eq(%w[
        0
        0_0
        0_0_0
        0_0_0_0
        0_0_0_1
        0_0-1
        0_0_0-1
        0_0_0_0-1
        0_0_0_1-1
        0_0-2
        0_0_0-2
        0_0_0_0-2
        0_0_0_1-2
        0_0-3
        0_0_0-3
        0_0_0_0-3
        0_0_0_1-3
        0_0_1-3
        0_0_1_0-3
      ].join("\n"))
    end

    it 'takes the first att child as tag' do

      flon = %{
        loop 'xyz'
          break _ if "$(nid)" == "0_1_0_0-2"
          #fail "hard"
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        receive:0:
        entered:0:xyz
        execute:0_1:
        execute:0_1_0:
        execute:0_1_0_0:
        receive:0_1_0:
        execute:0_1_0_1:
        receive:0_1_0:
        receive:0_1:
        receive:0:
        execute:0_1-1:
        execute:0_1_0-1:
        execute:0_1_0_0-1:
        receive:0_1_0-1:
        execute:0_1_0_1-1:
        receive:0_1_0-1:
        receive:0_1-1:
        receive:0:
        execute:0_1-2:
        execute:0_1_0-2:
        execute:0_1_0_0-2:
        receive:0_1_0-2:
        execute:0_1_0_1-2:
        receive:0_1_0-2:
        receive:0_1-2:
        execute:0_1_1-2:
        execute:0_1_1_0-2:
        receive:0_1_1-2:
        cancel:0:
        cancel:0_1-2:
        cancel:0_1_1-2:
        receive:0_1-2:
        receive:0:
        receive::
        left:0:xyz
        terminated::
      ].join("\n"))
    end
  end
end

