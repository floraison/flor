
#
# specifying flor
#
# Sat Jan 20 08:19:37 JST 2018  Between SIN and HIJ
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'includes?' do

    [

      %q{ includes? [ 0 ] 0 },
      %q{ includes? [ [ 0 ] ] [ 0 ] },
      %q{ includes? { a: 'A' } 'a' },

    ].each do |code|

      it "returns true for `#{code.strip}`" do

        r = @executor.launch(code)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(true)
      end
    end

    [

      %q{ includes? [] 0 },
      %q{ includes? [] [] },
      %q{ includes? { a: 'A' } 'b' },

    ].each do |code|

      it "returns false for `#{code.strip}`" do

        r = @executor.launch(code)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(false)
      end
    end

    it 'fails if the collection is missing' do

      r = @executor.launch(
        %q{
          includes? 1
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('Missing collection')
    end
  end
end

