
#
# specifying flor
#
# Mon Apr  4 09:49:01 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  # NOTA BENE: using "concurrence" even though it's deemed "unit" and not "core"

  describe 'until' do

    it 'has no effect when it has no children' do

      flor = %{
        7
        until _
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
    end

    it 'loops until the condition evaluates to true' do

      flor = %{
        123
        set f.a 1
        until
          = f.a 3
          set f.a
            + f.a 1
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(3)
      expect(r['payload']['ret']).to eq(123)
    end

    it 'accepts a tag:' do

      flor = %{
        456
        set f.a 1
        until tag: 'xx'
          = f.a 2
          set f.a (+ f.a 1)
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(2)
      expect(r['payload']['ret']).to eq(456)

      expect(
        @executor.journal
          .select { |m| %w[ entered left ].include?(m['point']) }
          .collect { |m| [ m['point'], m['nid'], m['tags'].join(',') ] }
          .collect { |a| a.join(':') }
          .join("\n")
      ).to eq(%w[
        entered:0_2:xx
        left:0_2:xx
      ].join("\n"))
    end

    it "returns the last child's f.ret" do

      flor = %{
        789
        set f.a 1
        #until; = f.a 3
        until (= f.a 3)
          set f.a
            + f.a 1
          + f.a 10
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(13)
    end

    it "doesn't iterate if the condition is immediately true" do

      flor = %{
        123
        set f.a 1
        until; = f.a 1
          6
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(123)
    end

    it 'stops upon meeting "break"' do

      flor = %{
        123
        set f.a 1
        until
          = f.a 3
          break _ # will return $(f.ret) (which is 123)
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(1)
      expect(r['payload']['ret']).to eq(123)
    end

    it 'stops upon meeting "break x" and returns x' do

      flor = %{
        set f.a 1
        until
          = f.a 3
          break "over"
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(1)
      expect(r['payload']['ret']).to eq('over')
    end

    it 'skips upon meeting "continue"' do

      flor = %{
        set f.a 0
        until
          = f.a 3
          push f.l f.a
          set f.a (+ f.a 1)
          continue _
          push f.l 'x'
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, 1, 2 ])
    end

    it 'respects an outer "break"' do

      flor = %{
        until
          false
          push f.l 0
          set outer-break break
          until false
            push f.l 'a'
            outer-break 'x'
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('x')
      expect(r['payload']['l']).to eq([ 0, 'a' ])
    end

    it 'can do an outer break ref: x' do

      flor = %{
        456
        until tag: 'main'
          false
          push f.l 0
          until false
            push f.l 'a'
            break 'x', ref: 'main'
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('x')
      expect(r['payload']['l']).to eq([ 0, 'a' ])
    end

    it 'respects an outer "continue"' do

      flor = %{
        123
        set f.i 0
        set f.j 0
        until (= f.i 2)
          set outer-continue continue
          push f.l "i$(f.i)"
          set f.i (+ f.i 1)
          until (= f.j 2)
            push f.l "j$(f.j)"
            set f.j (+ f.j 1)
            outer-continue _ if (= f.i 1)
            push f.l "jj$(f.j)"
          push f.l "ii$(f.i)"
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ i0 j0 i1 j1 jj2 ii2 ])
      expect(r['payload']['ret']).to eq(123)
    end

    it 'can do an outer continue ref: x' do

      flor = %{
        set f.i 0
        set f.j 0
        until (= f.i 2), tag: 'out'
          push f.l "i$(f.i)"
          set f.i (+ f.i 1)
          until (= f.j 2)
            push f.l "j$(f.j)"
            set f.j (+ f.j 1)
            continue ref: 'out', if (= f.i 1)
            push f.l "jj$(f.j)"
          push f.l "ii$(f.i)"
      }

      r = @executor.launch(flor, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq(%w[ i0 j0 i1 j1 jj2 ii2 ])
    end

    context 're-break/continue' do

      it 'rejects "break" when breaking' do

        flor = %{
          concurrence
            until tag: 'x0'
              sequence
                sequence
                  sequence
                    sequence
                      sequence
                        stall _
            sequence
              break 0 ref: 'x0'
              break 1 ref: 'x0'
        }

        r = @executor.launch(flor, archive: true)

        expect(r['point']).to eq('terminated')
        #expect(r['payload']['ret']).to eq(1)

        expect(
          @executor.journal.select { |m| m['point'] == 'receive' }.size
        ).to eq(
          25
        )

        unt = @executor.archive.values.find { |n| n['heap'] == 'until' }

        expect(unt['on_receive_last']).to eq(nil)

        expect(
          F.to_s(unt, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_0_1 m:54)
          (status closed pt:cancel fla:break fro:0_1_0 m:28)
          (status o pt:execute)
        }.ftrim)
      end

      it 'accepts "break" when continuing' do

        flor = %{
          set l []
          concurrence
            until false tag: 'x0'
              push l 'a'
              sequence
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
              _skip 7
              push l 'b'
              continue 0 ref: 'x0'
              push l 'c'
              break 1 ref: 'x0'
        }

        r = @executor.launch(flor, archive: true)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(nil)
        expect(r['vars']['l']).to eq(%w[ a b c ])

        unt = @executor.archive.values.find { |n| n['heap'] == 'until' }

        expect(unt['on_receive_last']).to eq(nil)
        expect(unt.has_key?('on_receive_last')).to eq(true)

        expect(
          F.to_s(unt, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_1_0_3 m:109)
          (status closed pt:cancel fla:break fro:0_1_1_4 m:104)
          (status closed pt:cancel fla:continue fro:0_1_1_2 m:67)
          (status o pt:execute)
        }.ftrim)
      end

      it 'rejects "continue" when breaking' do

        flor = %{
          set l []
          concurrence
            until false tag: 'x0'
              push l 'a'
              sequence
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
              _skip 3
              push l 'b'
              break 0 ref: 'x0'
              push l 'c'
              continue 1 ref: 'x0'
        }

        r = @executor.launch(flor, archive: true)

        expect(r['point']).to eq('terminated')
        #expect(r['payload']['ret']).to eq(0) # concurrence takes 1st reply
        expect(r['vars']['l']).to eq(%w[ a b c ])

        unt = @executor.archive.values.find { |n| n['heap'] == 'until' }

        expect(unt['on_receive_last']).to eq(nil)
        expect(unt.has_key?('on_receive_last')).to eq(true)

        expect(
          F.to_s(unt, :status)
        ).to eq(%{
          (status ended pt:receive fro:0_1_0_3 m:104)
          (status closed pt:cancel fla:break fro:0_1_1_2 m:63)
          (status o pt:execute)
        }.ftrim)
      end
    end
  end

  describe 'while' do

    it 'has no effect when it has no children' do

      flor = %{
        8
        while _
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(8)
    end

    it 'loops until the condition evaluates to false' do

      flor = %{
        set f.a 1
        while
          f.a < 3
          set f.a
            + f.a 1
          - f.a 1
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
      expect(r['payload']['a']).to eq(3)
    end

    it "returns the last child's f.ret" do

      flor = %{
        set f.a 1
        #while; < f.a 3
        while (< f.a 3)
          set f.a
            + f.a 1
          + f.a 20
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(23)
    end

    it "doesn't iterate if the condition is immediately false" do

      flor = %{
        set f.a 0
        while; = f.a 1
          #6
      }

      r = @executor.launch(flor)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'stops upon meeting "break"' do

      flor = %{
        456
        set f.i 0
        while (< f.i 4)
          push f.l f.i
          break _
          set f.i (+ f.i 1)
      }

      r = @executor.launch(flor, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0 ])
      expect(r['payload']['ret']).to eq(456)
    end

    it 'stops upon meeting "break x" and returns x' do

      flor = %{
        set f.i 0
        while (< f.i 4)
          push f.l f.i
          break 'done.'
          set f.i (+ f.i 1)
      }

      r = @executor.launch(flor, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('done.')
      expect(r['payload']['l']).to eq([ 0 ])
    end

    it 'skips upon meeting "continue"' do

      flor = %{
        123
        set f.i 0
        while (< f.i 3)
          push f.l "a$(f.i)"
          set f.i (+ f.i 1)
          continue _ if (= f.i 1)
          push f.l "b$(f.i)"
      }

      r = @executor.launch(flor, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a0 a1 b2 a2 b3 ])
      expect(r['payload']['ret']).to eq(123)
    end

    it 'respects an outer "break"' do

      flor = %{
        set i 0
        while (< i 3)
          set outer-break break
          set i (+ i 1)
          push f.l "i$(i)"
          set j 0
          while (< j 3)
            set j (+ j 1)
            push f.l "i$(i)j$(j)"
            outer-break 'done.' if j = 2
      }

      r = @executor.launch(flor, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('done.')
      expect(r['payload']['l']).to eq(%w[ i1 i1j1 i1j2 ])
    end

    it 'respects an outer "continue"' do

      flor = %{
        set i 0
        while (< i 3)
          set outer-continue continue
          set i (+ i 1)
          push f.l "i$(i)"
          set j 0
          while (< j 3)
            set j (+ j 1)
            outer-continue _ if j = 2
            push f.l "i$(i)j$(j)"
      }

      r = @executor.launch(flor, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ i1 i1j1 i2 i2j1 i3 i3j1 ])
      expect(r['payload']['ret']).to eq(nil)
    end
  end
end

