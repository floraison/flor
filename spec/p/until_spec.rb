
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

      rad = %{
        7
        until _
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
    end

    it 'loops until a condition evaluates to true' do

      rad = %{
        set f.a 1
        until
          = f.a 3
          set f.a
            + f.a 1
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
      expect(r['payload']['a']).to eq(3)
    end

    it "returns the last child's f.ret"
  end

  describe 'while' do

    it 'has no effect when it has no children'
    it 'loops until a condition evaluates to true'
    it "returns the last child's f.ret"
  end
end

