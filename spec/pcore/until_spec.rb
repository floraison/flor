
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

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end
  end

  describe 'while' do

    it 'has no effect when it has no children' do

      flon = %{
        8
        while _
      }

      r = @executor.launch(flon)

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
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
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

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end
  end
end

