
#
# specifying flor
#
# Sun Feb  7 14:27:04 JST 2016
#

require 'spec_helper'


describe Flor do

  before :each do

    @cars = {
      'alpha' => { 'id' => 'FR1' },
      'bentley' => %w[ blower spur markv ]
    }
    @ranking = %w[ Anh Bob Charly ]
  end

  describe '.deep_get' do

    [
      [ :cars, 'simca', nil ],
      [ :cars, 'alpha', { 'id' => 'FR1' } ],
      [ :cars, 'alpha.id', 'FR1' ],

      [ :cars, 'bentley.1', 'spur' ],
      [ :cars, 'bentley.other', IndexError ],
      [ :cars, 'bentley.other.nada', IndexError ],

      [ :ranking, '0', 'Anh' ],
      [ :ranking, '1', 'Bob' ],
      [ :ranking, '-1', 'Charly' ],
      [ :ranking, '-2', 'Bob' ],
      [ :ranking, 'first', 'Anh' ],
      [ :ranking, 'last', 'Charly' ],

    ].each do |o, k, v|

      it "gets #{k.inspect}" do

        o = self.instance_eval("@#{o}")

        if v.is_a?(Class)
          expect { Flor.deep_get(o, k) }.to raise_error(v)
        else
          expect(Flor.deep_get(o, k)).to eq(v)
        end
      end
    end
  end

  describe '.deep_set' do

    it 'sets at the first level' do

      o = {}
      r = Flor.deep_set(o, 'a', 1)

      expect(o).to eq({ 'a' => 1 })
      expect(r).to eq(true)
    end
  end
end

