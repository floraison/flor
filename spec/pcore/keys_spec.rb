
#
# specifying flor
#
# Thu Nov 16 17:42:10 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'keys' do

    it 'returns the indexes for an array' do

      r = @executor.launch(
        %q{
          keys [ 1, 'b', 3 ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 0, 1, 2 ])
    end

    it 'returns the keys for an object' do

      r = @executor.launch(
        %q{
          keys { a: 'A', b: 'B' }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ a b ])
    end

    it 'returns the keys for the incoming ret' do

      r = @executor.launch(
        %q{
          { a: 'A', b: 'B' }
          keys _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ a b ])
    end

    it 'returns the keys for the last child' do

      r = @executor.launch(
        %q{
          keys
            { a: 'A', b: 'B' }
            { c: 'C', d: 'D' }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ c d ])
    end

    it 'fails when not array or object' do

      r = @executor.launch(
        %q{
          #keys _
          keys "x"
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq('received argument of class String, no keys')
    end

    it 'fails when no argument' do

      r = @executor.launch(
        %q{
          keys _
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq('no argument given')
    end
  end

  describe 'values' do

    it 'returns the indexes for an array' do

      r = @executor.launch(
        %q{
          values [ 1, 'to', true ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 1, 'to', true ])
    end

    it 'returns the values for an object' do

      r = @executor.launch(
        %q{
          values { a: 'A', b: 'B' }
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ A B ])
    end

    it 'returns the values for the incoming ret' do

      r = @executor.launch(
        %q{
          { a: 'A', b: 'B' }
          values _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ A B ])
    end

    it 'returns the values for the incoming ret (even with att)' do

      r = @executor.launch(
        %q{
          { a: 'A', b: 'B' }
          values tag: 'taggy'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ A B ])
    end

    it 'fails when not array or object' do

      r = @executor.launch(
        %q{
          values "x"
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq('received argument of class String, no values')
    end

    it 'fails when no argument' do

      r = @executor.launch(
        %q{
          values _
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq('no argument given')
    end
  end
end

