
#
# specifying flor
#
# Tue Mar 22 06:44:32 JST 2016
#

require 'spec_helper'


describe 'Flor a-to-z' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a procedure on its own' do

    it 'is returned' do

      rad = %{
        sequence
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ '_proc', 'sequence', -1 ])
    end
  end

  describe 'a procedure with a least a child' do

    it 'is executed' do

      rad = %{
        sequence _
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end
  end

  describe 'a variable as head' do

    it 'is derefenced upon application' do

      rad = %{
        set f.a
          sequence
        #$(f.a)
        f.a
          1
          2
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end
  end

  context 'common _att' do

    describe 'vars' do

      it 'does not set f.ret' do

        rad = %{
          sequence vars: { a: 1 }
        }

        r = @executor.launch(rad)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(nil)
      end
    end
  end
end

