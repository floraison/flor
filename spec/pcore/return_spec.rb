
#
# specifying flor
#
# Fri Nov 23 20:18:50 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'return' do

    it 'returns' do

      r = @executor.launch(%q{
        define f
          return 'b' if true
          'a'
        f _
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('b')
    end

    it 'returns from the deep' do

      r = @executor.launch(%q{
        define fa
          return 2
          1
        define fb
          return (+ 3 (fa _))
          4
        fb _
      })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(5)
    end

    it 'fails if not in a function' do

      r = @executor.launch(%q{
        return 'xxx'
      })

      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('Flor::FlorError')
      expect(r['error']['msg']).to eq('"return" outside of function')
      expect(r['error']['lin']).to eq(2)
      expect(r['error']['prc']).to eq('return')
    end
  end
end

