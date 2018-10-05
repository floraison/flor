
#
# specifying flor
#
# Fri Oct  5 13:02:33 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'split' do

    {

      'split "ab cd ef"' => %w[ ab cd ef ],
      'split "ab|cd|ef" "|"' => %w[ ab cd ef ],
      'split "ab|cd|ef" r/\|/' => %w[ ab cd ef ],
      'split "ab|cd|ef" (/\|/)' => %w[ ab cd ef ],
      '"ab|cd|ef"; split "|"' => %w[ | ],
      '"ab,cd,ef"; split r/,/' => %w[ ab cd ef ],
      '"ab cd ef"; split tag: "x"' => %w[ ab cd ef ],

    }.each do |k, v|

      it "yields #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end

    [

      'split 1',
      'split r/,/',
      'r/,/; split _',
      '123; split _',

    ].each do |c|

      it "fails for `#{c}`" do

        r = @executor.launch(c)

        expect(r['point']).to eq('failed')
        expect(r['error']['msg']).to eq('found no string to split')
      end
    end
  end
end

