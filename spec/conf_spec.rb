
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

    it 'fails when it cannot parse' do

      expect {
        Flor::Conf.prepare(%{\n version: 3.2.1 }, {})
      }.to raise_error(
        ArgumentError,
        "error while reading conf: don't know how to apply \"3.2.1\""
      )
    end
  end
end

