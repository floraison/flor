
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

    it 'goes {nid}-n for the subsequent cycles' do

      flon = %{
        cursor
          continue _ if "$(nid)" == '0_0_0_0'
          continue _ if "$(nid)" == '0_1_0_0-1'
      }

      r = @executor.launch(flon, journal: true)

      expect(
        @executor.journal
          .collect { |m| m['nid'] }.compact.uniq.join("\n")
      ).to eq(%w[
        0
        0_0
        0_0_0
        0_0_0_0
        0_0_0_1
        0_0_1
        0_0_1_0
        0_0-1
        0_0_0-1
        0_0_0_0-1
        0_0_0_1-1
        0_1-1
        0_1_0-1
        0_1_0_0-1
        0_1_0_1-1
        0_1_1-1
        0_1_1_0-1
        0_0-2
        0_0_0-2
        0_0_0_0-2
        0_0_0_1-2
        0_1-2
        0_1_0-2
        0_1_0_0-2
        0_1_0_1-2
      ].join("\n"))
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

    it 'accepts "move"' do

      flon = %{
        cursor
          push f.l 'a'
          move to: 'final'
          push f.l 'b'
          push f.l 'c' tag: 'final'
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a c ])
    end

    context 're-break/continue' do

      it 'accepts "break" when breaking' do

        flon = %{
          set l []
          concurrence
            cursor tag: 'x1'
              push l 'a'
              sequence
                sequence
                  sequence
                    sequence
                      sequence
                        sequence
                          sequence
                            sequence
                              stall _
            sequence
              _skip 1
              push l 'b'
              break 0 ref: 'x1'
              push l 'c'
              break 1 ref: 'x1'
        }

        r = @executor.launch(flon, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(1)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor['status']).to eq('broken')
        expect(cursor['on_receive_last']).to eq(nil)
      end

      it 'accepts "break" when continuing' do

        flon = %{
          set l []
          concurrence
            cursor tag: 'x2'
              push l 'a'
              sequence
                sequence
                  sequence
                    sequence
                      sequence
                        sequence
                          sequence
                            sequence
                              stall _
            sequence
              _skip 1
              push l 'b'
              continue 0 ref: 'x2'
              push l 'c'
              break 1 ref: 'x2'
        }

        r = @executor.launch(flon, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(1)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor['status']).to eq('broken')
        expect(cursor.has_key?('on_receive_last')).to eq(false)
      end

      it 'rejects "continue" when breaking' do

        flon = %{
          set l []
          concurrence
            cursor tag: 'x3'
              push l 'a'
              sequence
                sequence
                  sequence
                    sequence
                      sequence
                        sequence
                          sequence
                            sequence
                              stall _
            sequence
              _skip 1
              push l 'b'
              break 0 ref: 'x3'
              push l 'c'
              continue 1 ref: 'x3'
        }

        r = @executor.launch(flon, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(0)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor['status']).to eq('broken')
        expect(cursor.has_key?('on_receive_last')).to eq(false)
      end

      it 'rejects "move" when breaking' do

        flon = %{
          set l []
          concurrence
            cursor tag: 'x3'
              push l 'a'
              sequence
                sequence
                  sequence
                    sequence
                      sequence ref: 'z'
                        sequence
                          sequence
                            sequence
                              stall _
            sequence
              _skip 1
              push l 'b'
              break 0 ref: 'x3'
              push l 'c'
              move 'x3' to: 'z'
        }

        r = @executor.launch(flon, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(0)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor['status']).to eq('broken')
        expect(cursor.has_key?('on_receive_last')).to eq(false)
      end
    end
  end
end

