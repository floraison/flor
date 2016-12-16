
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

  describe 'until' do

    it 'has no effect when it has no children' do

      flon = %{
        7
        until _
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
    end

    it 'loops until the condition evaluates to true' do

      flon = %{
        set f.a 1
        until
          = f.a 3
          set f.a
            + f.a 1
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(3)
      expect(r['payload']['ret']).to eq(nil)
    end

    it "returns the last child's f.ret" do

      flon = %{
        set f.a 1
        #until; = f.a 3
        until (= f.a 3)
          set f.a
            + f.a 1
          + f.a 10
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(13)
    end

    it "doesn't iterate if the condition is immediately true" do

      flon = %{
        set f.a 1
        until; = f.a 1
          #6
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'stops upon meeting "break"' do

      flon = %{
        set f.a 1
        until
          = f.a 3
          break _ # will return $(f.ret) (which is false)
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(1)
      expect(r['payload']['ret']).to eq(false)
    end

    it 'stops upon meeting "break x" and returns x' do

      flon = %{
        set f.a 1
        until
          = f.a 3
          break "over"
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(1)
      expect(r['payload']['ret']).to eq('over')
    end

    it 'skips upon meeting "continue"' do

      flon = %{
        set f.a 0
        until
          = f.a 3
          push f.l f.a
          set f.a (+ f.a 1)
          continue _
          push f.l 'x'
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ 0, 1, 2 ])
    end

    it 'respects an outer "break"' do

      flon = %{
        until
          false
          push f.l 0
          set outer-break break
          until false
            push f.l 'a'
            outer-break 'x'
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('x')
      expect(r['payload']['l']).to eq([ 0, 'a' ])
    end

    it 'can do an outer break ref: x' do

      flon = %{
        until false, 'fuk', tag: 'main'
        #until tag: 'main'
          #false
          fail 'fast'
          push f.l 0
          until false
            push f.l 'a'
            break 'x', ref: 'main'
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('x')
      expect(r['payload']['l']).to eq([ 0, 'a' ])
    end

    it 'respects an outer "continue"' do

      flon = %{
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

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq(%w[ i0 j0 i1 j1 jj2 ii2 ])
    end

    it 'can do an outer continue ref: x'
  end

  describe 'while' do

    it 'has no effect when it has no children' do

      flon = %{
        8
        while _
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(8)
    end

    it 'loops until the condition evaluates to false' do

      flon = %{
        set f.a 1
        while
          f.a < 3
          set f.a
            + f.a 1
          - f.a 1
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
      expect(r['payload']['a']).to eq(3)
    end

    it "returns the last child's f.ret" do

      flon = %{
        set f.a 1
        #while; < f.a 3
        while (< f.a 3)
          set f.a
            + f.a 1
          + f.a 20
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(23)
    end

    it "doesn't iterate if the condition is immediately false" do

      flon = %{
        set f.a 0
        while; = f.a 1
          #6
      }

      r = @executor.launch(flon)

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'stops upon meeting "break"' do

      flon = %{
        set f.i 0
        while (< f.i 4)
          push f.l f.i
          break _
          set f.i (+ f.i 1)
      }

      r = @executor.launch(flon, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
      expect(r['payload']['l']).to eq([ 0 ])
    end

    it 'stops upon meeting "break x" and returns x' do

      flon = %{
        set f.i 0
        while (< f.i 4)
          push f.l f.i
          break 'done.'
          set f.i (+ f.i 1)
      }

      r = @executor.launch(flon, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('done.')
      expect(r['payload']['l']).to eq([ 0 ])
    end

    it 'skips upon meeting "continue"' do

      flon = %{
        set f.i 0
        while (< f.i 3)
          push f.l "a$(f.i)"
          set f.i (+ f.i 1)
          continue _ if (= f.i 1)
          push f.l "b$(f.i)"
      }

      r = @executor.launch(flon, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq(%w[ a0 a1 b2 a2 b3 ])
    end

    it 'respects an outer "break"' do

      flon = %{
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

      r = @executor.launch(flon, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('done.')
      expect(r['payload']['l']).to eq(%w[ i1 i1j1 i1j2 ])
    end

    it 'respects an outer "continue"' do

      flon = %{
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

      r = @executor.launch(flon, :payload => { 'l' => [] })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 ])

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ i1 i1j1 i2 i2j1 i3 i3j1 ])
      expect(r['payload']['ret']).to eq(true)
    end
  end
end

