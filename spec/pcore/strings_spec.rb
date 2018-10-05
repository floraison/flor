
#
# specifying flor
#
# Wed Oct  3 11:31:29 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'downcase, lowercase, lowcase' do

    {

      'downcase "NADA"' => 'nada',
      'lowercase "NADA"' => 'nada',
      'lowcase "NADA"' => 'nada',
      'downcase "NADA" "HELLO"' => 'hello',
      '"Bonjour"; downcase _' => 'bonjour',
      '"Bonjour"; downcase "XYZ"' => 'xyz',

      '[ "A" "BC" "D" ]; downcase _' => %w[ a bc d ],
      '{ a: "A" b: "BC" }; downcase _' => { 'a' => 'a', 'b' => 'bc' },

      'downcase [ "A" "BC" "DE" ]' => %w[ a bc de ],
      'downcase { a: "A" b: "B" }' => { 'a' => 'a', 'b' => 'b' },

      'downcase "NADA" tag: "XXx"' => 'nada',
      '"Jocko"; downcase tag: "XXx"' => 'jocko',

      'downcase "NADA" tag: "XXx" cap: true' => 'Nada',

    }.each do |k, v|

      it "returns #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end

  describe 'upcase, uppercase' do

    {

      'upcase "nada"' => 'NADA',
      '"world"; upcase _' => 'WORLD',
      '[ "a" "bc" "d" ]; upcase _' => %w[ A BC D ],
      '{ a: "a" b: "bc" }; upcase _' => { 'a' => 'A', 'b' => 'BC' },

    }.each do |k, v|

      it "returns #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end

  describe 'capitalize' do

    {

      'capitalize "nada"' => 'Nada',
      '"world"; capitalize _' => 'World',
      '[ "fox" "bros" "wool" ]; capitalize _' => %w[ Fox Bros Wool ],
      '{ a: "al" b: "bob" }; capitalize _' => { 'a' => 'Al', 'b' => 'Bob' },

      'capitalize "banana republic"' => 'Banana Republic',

    }.each do |k, v|

      it "returns #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end

  describe 'snakecase, snake_case' do

    {

      'snakecase "OnBoard or OffLine"' => 'on_board or off_line',
      '"MessageBoard"; snake_case tag: "y"' => 'message_board',

    }.each do |k, v|

      it "returns #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end

  describe 'camelcase, camelCase' do

    {

      'camelcase "on_line or off_line"' => 'onLine or offLine',
      '"off_limits"; camelcase tag: "y"' => 'offLimits',

    }.each do |k, v|

      it "returns #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end

  describe 'strip, trim' do

    {

      'strip " orly "' => 'orly',
      '" orly "; strip _' => 'orly',
      '" orly "; strip cap: 1' => 'Orly',
      '" orly "; trim _' => 'orly',

    }.each do |k, v|

      it "returns #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end
end

