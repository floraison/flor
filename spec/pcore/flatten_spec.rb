
#
# specifying flor
#
# Mon Aug 13 11:47:02 CEST 2018  Neyruz
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'flatten' do

    {

      [ [ 1, 2, 3 ], nil ] => [ 1, 2, 3 ],
      [ [ 1, [ 2, 3 ], 4 ], nil ] => [ 1, 2, 3, 4 ],
      [ [ 1, [ 2, 3 ], 4 ], 1 ] => [ 1, 2, 3, 4 ],
      [ [ 1, [ 2, [ 3 ] ], 4 ], 1 ] => [ 1, 2, [ 3 ], 4 ],

    }.each do |(arr, arg), ret|

      it "returns #{ret.inspect} for `flatten #{arr.inspect}`" do

        r =
          @executor.launch(%{
            flatten #{arr.inspect} #{arg.to_s}
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(ret)
      end
    end

    it 'flattens f.ret' do

      r =
        @executor.launch(%{
          [ 1, [ 2, [ 3 ] ], 4 ]
          flatten _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, 3, 4 ])
    end

    it 'flattens f.ret' do

      r =
        @executor.launch(%{
          [ 1, [ 2, [ 3 ] ], 4 ]
          flatten 1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 2, [ 3 ], 4 ])
    end

    it 'fails if it is not given an array' do

      r =
        @executor.launch(%{
          flatten _
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('missing collection')
    end
  end
end

