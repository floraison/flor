
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

      'capitalize "banana republic"' => 'Banana republic',

    }.each do |k, v|

      it "returns #{v.inspect} for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end
end

