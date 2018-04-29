
#
# specifying flor
#
# Wed Apr  6 14:50:53 JST 2016
#

require 'spec_helper'


describe Flor::Conf do

  describe '.prepare' do

    it 'reads a file and returns the object content' do

      h =
        Flor::Conf.prepare(
          %{
            colour: blue
            name: stuff
            version: '3.2.1'
            count: 7
            blah: [ 'a', 'b', 2 ]
          },
          {})

      expect(h).to eq({
        'colour' => 'blue',
        'name' => 'stuff',
        'version' => '3.2.1',
        'count' => 7,
        'blah' => [ 'a', 'b', 2 ],
        'root' => '.'
      })
    end

    it 'fails if it cannot parse' do

      expect {
        p Flor::Conf.prepare(%{\n version: 3.2.1 }, {})
      }.to raise_error(
        ArgumentError, 'Error while reading conf: Variable "3" not found'
      )
    end

    it 'does not use "unit" procedures' do

      expect(
        Flor::Conf.prepare(%{\n point: cancel }, {})
      ).to eq({
        'point' => 'cancel', 'root' => '.'
      })
    end
  end
end

