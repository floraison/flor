
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

      r = @executor.launch(
        %q{
          cursor
            push f.l 0
            push f.l 1
          push f.l 2
        },
        payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq([ 0, 1, 2 ])
    end

    it 'understands break' do

      r = @executor.launch(
        %q{
          cursor
            push f.l node.nid
            break _
            push f.l node.nid
          push f.l node.nid
        },
        payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ 0_0_0_1 0_1_1 ])
    end

    it 'understands continue' do

      r = @executor.launch(
        %q{
          cursor
            push f.l node.nid
            continue _ if node.nid == '0_1_0_0'
            push f.l node.nid
        }, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ 0_0_1 0_0_1-1 0_2_1-1 ])
    end

    it 'understands an outer "continue"' do

      r = @executor.launch(
        %q{
          cursor
            set outer-continue continue
            push f.l node.nid
            cursor
              push f.l node.nid
              outer-continue _ if node.nid == '0_2_1_0_0'
        },
        payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ 0_1_1 0_2_0_1 0_1_1-1 0_2_0_1-1 ])
    end

    it 'goes {nid}-n for the subsequent cycles' do

      r = @executor.launch(
        %q{
          cursor
            continue _ if node.nid == '0_0_0_0'
            continue _ if node.nid == '0_1_0_0-1'
        })

      expect(r).to have_terminated_as_point

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        execute:0_0_0_0:
        execute:0_0_0_0_0:
        receive:0_0_0_0:
        execute:0_0_0_0_1:
        receive:0_0_0_0:
        receive:0_0_0:
        execute:0_0_0_1:
        receive:0_0_0:
        receive:0_0:
        execute:0_0_1:
        execute:0_0_1_0:
        receive:0_0_1:
        cancel:0:
        cancel:0_0:
        cancel:0_0_1:
        receive:0_0:
        receive:0:
        execute:0_0-1:
        execute:0_0_0-1:
        execute:0_0_0_0-1:
        execute:0_0_0_0_0-1:
        receive:0_0_0_0-1:
        execute:0_0_0_0_1-1:
        receive:0_0_0_0-1:
        receive:0_0_0-1:
        execute:0_0_0_1-1:
        receive:0_0_0-1:
        receive:0_0-1:
        receive:0:
        execute:0_1-1:
        execute:0_1_0-1:
        execute:0_1_0_0-1:
        execute:0_1_0_0_0-1:
        receive:0_1_0_0-1:
        execute:0_1_0_0_1-1:
        receive:0_1_0_0-1:
        receive:0_1_0-1:
        execute:0_1_0_1-1:
        receive:0_1_0-1:
        receive:0_1-1:
        execute:0_1_1-1:
        execute:0_1_1_0-1:
        receive:0_1_1-1:
        cancel:0:
        cancel:0_1-1:
        cancel:0_1_1-1:
        receive:0_1-1:
        receive:0:
        execute:0_0-2:
        execute:0_0_0-2:
        execute:0_0_0_0-2:
        execute:0_0_0_0_0-2:
        receive:0_0_0_0-2:
        execute:0_0_0_0_1-2:
        receive:0_0_0_0-2:
        receive:0_0_0-2:
        execute:0_0_0_1-2:
        receive:0_0_0-2:
        receive:0_0-2:
        receive:0:
        execute:0_1-2:
        execute:0_1_0-2:
        execute:0_1_0_0-2:
        execute:0_1_0_0_0-2:
        receive:0_1_0_0-2:
        execute:0_1_0_0_1-2:
        receive:0_1_0_0-2:
        receive:0_1_0-2:
        execute:0_1_0_1-2:
        receive:0_1_0-2:
        receive:0_1-2:
        receive:0:
        receive::
        terminated::
      ].join("\n"))
    end

    it 'takes the first att child as tag' do

      r = @executor.launch(
        %q{
          cursor 'main'
            set f.done true
        })

      expect(r).to have_terminated_as_point

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
        execute:0_1_0_0:
        receive:0_1_0:
        execute:0_1_0_1:
        receive:0_1_0:
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

      r = @executor.launch(
        %q{
          cursor
            push f.l 'a'
            move to: 'final'
            push f.l 'b'
            push f.l 'c' tag: 'final'
        },
        payload: { 'l' => [] })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ a c ])
    end

    it 'accepts "move" as final child' do

      r = @executor.launch(
        %q{
          cursor
            push f.l 'a' tag: 'a'
            break _ if node.nid == '0_1_0_0-1'
            move to: 'a'
        },
        payload: { 'l' => [] })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ a a ])
    end

    context 're-break/continue' do

      it 'accepts "break" when breaking' do

        r = @executor.launch(
          %q{
            set l []
            concurrence
              cursor tag: 'x1'
                push l 'a'
                stall _
              sequence
                _skip 1
                push l 'b'
                break 0 ref: 'x1'
                push l 'c'
                break 1 ref: 'x1'
          },
          archive: true)

        expect(r).to have_terminated_as_point
        expect(r['vars']['l']).to eq(%w[ a b c ])
        #expect(r['payload']['ret']).to eq(1)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(
          F.to_s(cursor, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_1_0 m:64)
          (status closed pt:cancel fla:break fro:0_1_1_2 m:58)
          (status o pt:execute)
        }.ftrim)
        expect(
          cursor['on_receive_last']
        ).to eq(
          nil
        )
      end

      it 'accepts "break" when continuing' do

        r = @executor.launch(
          %q{
            set l []
            concurrence
              cursor tag: 'x2'
                push l 'a'
                stall _
              sequence
                _skip 1
                push l 'b'
                continue 0 ref: 'x2'
                push l 'c'
                break 1 ref: 'x2'
                2
          },
          archive: true)

        expect(r).to have_terminated_as_point
        expect(r['vars']['l']).to eq(%w[ a b c a ])
        expect(r['payload']['ret']).to eq(1)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor['on_receive_last']).to eq(nil)
        expect(cursor.has_key?('on_receive_last')).to eq(true)

        expect(
          F.to_s(cursor, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_1_0 m:98)
          (status closed pt:cancel fla:break fro:0_1_1_4 m:92)
          (status o pt:receive fro:0_1_0_2 m:62)
          (status closed pt:cancel fla:continue fro:0_1_1_2 m:58)
          (status o pt:execute)
        }.ftrim)

        expect(
          cursor['on_receive_last']
        ).to eq(
          nil
        )
      end

      it 'accepts "break" when continuing (nest-1)' do

        r = @executor.launch(
          %q{
            set l []
            concurrence
              cursor tag: 'x2'
                push l 'a'
                stall _
              sequence
                _skip 1
                push l 'b'
                continue 0 ref: 'x2'
                push l 'c'
                break 1 ref: 'x2'
                2
          },
          archive: true)

        expect(r).to have_terminated_as_point
        expect(r['vars']['l']).to eq(%w[ a b c a ])
        expect(r['payload']['ret']).to eq(1)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor['on_receive_last']).to eq(nil)
        expect(cursor.has_key?('on_receive_last')).to eq(true)

        expect(
          F.to_s(cursor, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_1_0 m:98)
          (status closed pt:cancel fla:break fro:0_1_1_4 m:92)
          (status o pt:receive fro:0_1_0_2 m:62)
          (status closed pt:cancel fla:continue fro:0_1_1_2 m:58)
          (status o pt:execute)
        }.ftrim)
      end

      it 'rejects "continue" when breaking' do

        r = @executor.launch(
          %q{
            set l []
            concurrence
              cursor tag: 'x3'
                push l 'a'
                stall _
              sequence
                _skip 1
                push l 'b'
                break 0 ref: 'x3'
                push l 'c'
                continue 'x' ref: 'x3'
                2
          },
          archive: true)

        expect(r).to have_terminated_as_point
        expect(r['vars']['l']).to eq(%w[ a b c ])
        #expect(r['payload']['ret']).to eq(0)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor.has_key?('on_receive_last')).to eq(true)
        expect(cursor['on_receive_last']).to eq(nil)

        expect(
          F.to_s(cursor, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_1_0 m:64)
          (status closed pt:cancel fla:break fro:0_1_1_2 m:58)
          (status o pt:execute)
        }.ftrim)
      end

      it 'rejects "move" when breaking' do

        r = @executor.launch(
          %q{
            set l []
            concurrence
              cursor tag: 'x3'
                push l 'a'
                sequence ref: 'z'
                  stall _
              sequence
                _skip 1
                push l 'b'
                break 0 ref: 'x3'
                push l 'c'
                move 'x3' to: 'z'
                2
          },
          archive: true)

        expect(r).to have_terminated_as_point
        expect(r['vars']['l']).to eq(%w[ a b c ])
        expect(r['payload']['ret']).to eq(0)

        cursor = @executor.archive.values.find { |n| n['heap'] == 'cursor' }

        expect(cursor.has_key?('on_receive_last')).to eq(true)
        expect(cursor['on_receive_last']).to eq(nil)

        expect(
          F.to_s(cursor, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_1_0 m:75)
          (status closed pt:cancel fla:break fro:0_1_1_2 m:65)
          (status o pt:execute)
        }.ftrim)
      end
    end

    it 'accepts a var: attribute' do

      # those procedures with a local variable scope, they create it
      # before processing the vars: attribute, and this attributes simply
      # merges in that existing local scope

      r = @executor.launch(
        %q{
          cursor vars: { a: 0, b: 1 }
            0
        },
        wait: true)

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq(0)
      expect(r['vars'].keys).to eq(%w[ break continue move a b ])
    end
  end
end

