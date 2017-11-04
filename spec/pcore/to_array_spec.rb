
#
# specifying flor
#
# Sun Nov  5 07:19:07 JST 2017  Singapore
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'to-array' do

    it 'leaves an Array intact' do

      r = @executor.launch(
        %q{
          [ 0 1 2 3 4 5 6 7 ]
          to-array _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq((0..7).to_a)
    end

    it 'wraps atoms in an array' do

      r = @executor.launch(
        %q{
          [
            (to-array 123)
            (to-array true)
          ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ [ 123 ], [ true ] ])
    end

    it 'turns an object into an array' do

      r = @executor.launch(
        %q{
          to-array { a: 'A', b: 'B' }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ %w[ a A ], %w[ b B ] ])
    end
  end
end

