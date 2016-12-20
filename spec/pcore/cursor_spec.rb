
#
# specifying flor
#
# Mon Dec 19 11:27:09 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'cursor' do

    it 'goes from a to b and exits' do

      flon = %{
        cursor
          push f.l 0
          push f.l 1
        push f.l 2
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, 1, 2 ])
    end

    it 'understands break' do

      flon = %{
        cursor
          push f.l "$(nid)"
          break _
          push f.l "$(nid)"
        push f.l "$(nid)"
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_0_0_1 0_1_1 ])
    end

    it 'understands continue' do

      flon = %{
        cursor
          push f.l "$(nid)"
          continue _ if "$(nid)" == '0_1_0_0'
          push f.l "$(nid)"
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_0_1 0_0_1-1 0_2_1-1 ])
    end

    it 'takes the first att child as tag' do

      flon = %{
        cursor 'main'
          set f.done true
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
        entered:0:main
        execute:0_1:
        execute:0_1_0:
        receive:0_1:
        execute:0_1_1:
        receive:0_1:
        receive:0:
        receive::
        left:0:main
        terminated::
      ].join("\n"))
    end
  end
end

