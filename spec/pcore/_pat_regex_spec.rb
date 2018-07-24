
#
# specifying flor
#
# Tue Jul 11 07:51:31 JST 2017   圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_regex' do

    [

      [ "/o/", 'nada',
        nil ],
      [ "/a/", 'nada',
        { 'matched' => 'nada', 'match' => [ 'a' ] } ],
      [ "/^na(.+)/", 'nada',
        { 'matched' => 'nada', 'match' => [ 'nada', 'da' ] } ],

    ].each do |code, val, expected|

      code = [ '_pat_regex', [ [ '_sqs', code[1..-2], 1 ] ], 1 ]
      c = code.inspect

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

