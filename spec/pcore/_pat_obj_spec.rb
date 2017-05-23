
#
# specifying flor
#
# Tue May 23 06:15:46 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_obj' do

    [

      [ %q{ _pat_obj \ a; 1 }, 1, nil ],
      [ %q{ _pat_obj \ a; 1 }, { 'a' => 2 }, nil ],
      [ %q{ _pat_obj \ a; 1 }, { 'a' => 1 }, {} ],
      [ %q{ _pat_obj \ a; b }, { 'a' => 2 }, { 'b' => 2 } ],

    ].each do |code, val, expected|

      it(
        "#{expected == nil ? 'doesn\'t match' : 'matches'}" +
        " for `#{code.strip.to_s}` vs `#{val.inspect}`"
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

