
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Rad do

  context 'basic' do

    [
      [
        %{
          sequence
        },
        [ 'sequence', [], 2 ],
        __LINE__
      ],
      [
        %{
          sequence
            a
            b
        },
        [ 'sequence', [
          [ 'a', [], 3 ],
          [ 'b', [], 4 ]
        ], 2 ],
        __LINE__
      ],
      [
        %{
          sequence a b
        },
        [ 'sequence', [
          [ 'a', [], 2 ],
          [ 'b', [], 2 ]
        ], 2 ],
        __LINE__
      ],
      [
        %{
          sequence a, vars: 1, timeout: 1h, b
        },
        [ 'sequence', [
          [ 'attr', [
            [ 'vars', [], 2 ], [ 1, [], 2 ],
            [ 'timeout', [], 2 ], [ '1h', [], 2 ]
          ], 2 ],
          [ 'a', [], 2 ],
          [ 'b', [], 2 ]
        ], 2 ],
        __LINE__
      ],

    ].each do |ra, tr, li|

      rad = ra.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
      rad = "#{rad[0, 60]}..." if rad.length > 60
      title = "parses li#{li} `#{rad}`"

      it(title) do

        expect(Flor::Rad.parse(ra)).to eq(tr)
      end
    end
  end
end

