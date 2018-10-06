
#
# specifying flor
#
# Sun Apr  3 14:11:49 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'matchr' do

    {

      'matchr "alpha", /bravo/' => [],
      'matchr "stuff", /stuf*/' => %w[ stuff ],
      'matchr "stuff", /s(tu)(f*)/' => %w[ stuff tu ff ],
      'matchr "stuff", "stuf*"' => %w[ stuff ],
      'matchr "stUff", /stuff/i' => %w[ stUff ],

      '"blue moon" | matchr r/blue/' => %w[ blue ],
      '"blue moon" | matchr "moon"' => %w[ moon ],
      '"blue moon"; matchr r/blue/' => %w[ blue ],
      '"blue moon"; matchr "moon"' => %w[ moon ],

      'r/blue/ | matchr "blue moon"' => %w[ blue ],

    }.each do |k, v|

      so "`#{k}` yields #{v.inspect}" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to eq({ 'ret' => v })
      end
    end
  end

  describe 'match?' do

    it 'works alongside "if"' do

      r = @executor.launch(
        %q{
          push f.l
            if
              match? "stuff", "^stuf*$"
              'a'
              'b'
          push f.l
            if
              match? "staff", "^stuf*$"
              'c'
              'd'
          push f.l
            if
              match? "$(nothing)", "^stuf*$"
              'e'
              'f'
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ a d f ])
    end

    {

      'match? "stuff", "^stuf*$"' => true,
      'match? "stuff", "^Stuf*$"' => false,
      '"blue moon" | match? "moon"' => true,
      '"blue moon" | match? "x"' => false,

      'r/x/ | match? "blue moon"' => false,
      'r/x/ | match? "x moon"' => true,

    }.each do |k, v|

      so "`#{k}` yields #{v.inspect}" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']).to eq({ 'ret' => v })
      end
    end
  end

  describe 'pmatch' do

    {

      "pmatch 'string', /^str/" => 'str',
      "pmatch 'string', /^str(.+)$/" => 'ing',
      "pmatch 'string', /^str(?:.+)$/" => 'string',
      "pmatch 'strogonoff', /^str(?:.{0,3})(.*)$/" => 'noff',
      "pmatch 'sutoringu', /^str/" => '',

      "r/^str/ | pmatch 'sutoringu'" => '',
      "r/^str/ | pmatch 'string'" => 'str',
      "'sutoringu'; pmatch r/^str/" => '',
      "'string'; pmatch r/^str/" => 'str',

    }.each do |k, v|

      so "`#{k}` yields #{v.inspect}" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end
end

