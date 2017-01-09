
#
# specifying flor
#
# Mon Dec 19 11:27:09 JST 2016
#

require 'spec_helper'


describe 'Flor pcore' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  # NOTA BENE: using "concurrence" even though it's deemed "unit" and not "core"

  describe 'cursor' do

    it 'goes from a to b and exits' do

      flor = %{
        cursor
          push f.l 0
          push f.l 1
        push f.l 2
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, 1, 2 ])
    end

    it 'understands break' do

      flor = %{
        cursor
          push f.l "$(nid)"
          break _
          push f.l "$(nid)"
        push f.l "$(nid)"
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_0_0_1 0_1_1 ])
    end

    it 'understands continue' do

      flor = %{
        cursor
          push f.l "$(nid)"
          continue _ if "$(nid)" == '0_1_0_0'
          push f.l "$(nid)"
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_0_1 0_0_1-1 0_2_1-1 ])
    end

    it 'goes {nid}-n for the subsequent cycles' do

      flor = %{
        cursor
          continue _ if "$(nid)" == '0_0_0_0'
          continue _ if "$(nid)" == '0_1_0_0-1'
      }

      r = @executor.launch(flor)

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

      flor = %{
        cursor 'main'
          set f.done true
      }

      r = @executor.launch(flor)

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

      flor = %{
        cursor
          push f.l 'a'
          move to: 'final'
          push f.l 'b'
          push f.l 'c' tag: 'final'
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a c ])
    end

    it 'accepts "move" as final child' do

      flor = %{
        cursor
          push f.l 'a' tag: 'a'
          break _ if "$(nid)" == '0_1_0_0-1'
          move to: 'a'
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a a ])
    end

    context 're-break/continue' do

      it 'accepts "break" when breaking' do

        flor = %{
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

        r = @executor.launch(flor, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(1)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(
          cursor['status'][0, 4]
        ).to eq(
          [ 'broken', 'break', '0_1_1_4', 'broken' ]
        )
        expect(
          cursor['on_receive_last']
        ).to eq(
          nil
        )
      end

      it 'accepts "break" when continuing' do

        flor = %{
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

        r = @executor.launch(flor, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(1)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor.has_key?('on_receive_last')).to eq(false)

        expect(
          cursor['status'][0, 4]
        ).to eq(
          [ 'broken', 'break', '0_1_1_4', nil ]
        )
      end

      it 'rejects "continue" when breaking' do

        flor = %{
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
              continue 'x' ref: 'x3'
        }

        r = @executor.launch(flor, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(0)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor.has_key?('on_receive_last')).to eq(false)

        expect(
          cursor['status'][0, 4]
        ).to eq(
          [ 'broken', 'break', '0_1_1_2', nil ]
        )
      end

      it 'rejects "move" when breaking' do

        flor = %{
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

        r = @executor.launch(flor, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(0)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor.has_key?('on_receive_last')).to eq(false)

        expect(
          cursor['status'][0, 4]
        ).to eq(
          [ 'broken', 'break', '0_1_1_2', nil ]
        )
      end
    end
  end
end

