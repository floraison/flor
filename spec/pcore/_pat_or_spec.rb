
#
# specifying flor
#
# Thu May 25 09:02:23 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_or' do

    [

      [ %q{ _pat_or _ }, 11, nil ],
      [ %q{ _pat_or \ 10 }, 11, nil ],
      [ %q{ _pat_or \ 11 }, 11, {} ],
      [ %q{ _pat_or \ 10; 11 }, 11, {} ],

    ].each do |code, val, expected|

      c = code.is_a?(String) ? code.strip : code.inspect

      it(
        "#{expected == nil ? 'doesn\'t match' : 'matches'}" +
        " for `#{c}` vs `#{val.inspect}`"
      ) do

        r = @executor.launch(code, payload: { 'ret' => val })

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to have_key('_pat_binding')
        expect(r['payload']).not_to have_key('_pat_val')
        expect(r['payload']['_pat_binding']).to eq(expected)
      end
    end
  end
end

