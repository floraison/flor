
#
# specifying flor
#
# Thu May 11 11:03:25 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'not' do

    [
      [ %q{ not _ }, true ],
      [ %q{ not true }, false ],
      [ %q{ not false }, true ],
    ].each do |flor, ret|

      it "returns %-5s for `%s`" % [ ret, flor.strip ] do

        r = @executor.launch(flor)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(ret)
      end
    end

    it 'negates its last child' do

      r = @executor.launch(
        %q{
          not
            true
            false
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end

    it 'negates its last child (one-liner)' do

      r = @executor.launch(
        %q{ not \ true | false })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end
  end
end

