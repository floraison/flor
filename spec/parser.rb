
#
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
#

require 'spec_helper'

require 'flor/parser'


describe Flor::Rad do

  context 'atoms' do

    [
      [
        %{ 1 },
        [ '_num', 1, 1 ],
        __LINE__
      ],
      [
        %{ 11.01 },
        [ '_num', 11.01, 1 ],
        __LINE__
      ],
      [
        %{ true },
        [ '_boo', true, 1 ],
        __LINE__
      ],
      [
        %{ false },
        [ '_boo', false, 1 ],
        __LINE__
      ],
      [
        %{ null },
        [ '_nul', nil, 1 ],
        __LINE__
      ],
      [
        %{ abc },
        [ 'abc', [], 1 ],
        __LINE__
      ],
      [
        %{ 'def' },
        [ '_sqs', 'def', 1 ],
        __LINE__
      ],
      [
        %{ "ghi" },
        [ '_dqs', 'ghi', 1 ],
        __LINE__
      ],
      [
        %{ /jkl/i },
        [ '_rxs', '/jkl/i', 1 ],
        __LINE__
      ],
      [
        %{ [ 1, 2, 3 ] },
        [ '_arr', [
          [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 1 ]
        ], 1 ],
        __LINE__
      ],
      [
        %{ { a: A, b: 2, c: true } },
        [ '_obj', [
          [ 'a', [], 1 ], [ 'A', [], 1 ],
          [ 'b', [], 1 ], [ '_num', 2, 1 ],
          [ 'c', [], 1 ], [ '_boo', true, 1 ]
        ], 1 ],
        __LINE__
      ],
    ].each { |ra, tr, li|

      rad = ra.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
      rad = "#{rad[0, 60]}..." if rad.length > 60
      title = "parses li#{li} `#{rad}`"

      it(title) { expect(Flor::Rad.parse(ra)).to eq(tr) }
    }
  end

  context 'operations' do

    [
      [
        __LINE__,
        %{
          10 + 11 - 5
        },
        [ '-', [
          [ '+', [
            [ '_num', 10, 2 ],
            [ '_num', 11, 2 ]
          ], 2 ],
          [ '_num', 5, 2 ]
        ], 2 ]
      ],
      [
        __LINE__,
        %{
          1 + 1 * 2
        },
        [ '+', [
          [ '_num', 1, 2 ],
          [ '*', [
            [ '_num', 1, 2 ],
            [ '_num', 2, 2 ]
          ], 2 ]
        ], 2 ]
      ],
    ].each { |li, ra, tr|

      rad = ra.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
      rad = "#{rad[0, 60]}..." if rad.length > 60
      title = "parses li#{li} `#{rad}`"

      it(title) { expect(Flor::Rad.parse(ra)).to eq(tr) }
    }
  end

  context 'basic' do

    [
      [
        __LINE__,
        %{
          sequence
        },
        [ 'sequence', [], 2 ]
      ],
      [
        __LINE__,
        %{
          sequence
            a
            b
        },
        [ 'sequence', [
          [ 'a', [], 3 ],
          [ 'b', [], 4 ]
        ], 2 ]
      ],
      [
        __LINE__,
        %{
          sequence a b
        },
        [ 'sequence', [
          [ 'a', [], 2 ],
          [ 'b', [], 2 ]
        ], 2 ]
      ],
      [
        __LINE__,
        %{
          sequence a, vars: 1, timeout: 1h, b
        },
        [ 'sequence', [
          [ '_atts', [
            [ 'vars', [], 2 ], [ '_num', 1, 2 ],
            [ 'timeout', [], 2 ], [ '1h', [], 2 ]
          ], 2 ],
          [ 'a', [], 2 ],
          [ 'b', [], 2 ]
        ], 2 ]
      ],
      [
        __LINE__,
        %{
          sequence a: 1 + 1, 2
        },
        [ 'sequence', [
          [ '_atts', [
            [ 'a', [], 2 ],
            [ '+', [
              [ '_num', 1, 2 ],
              [ '_num', 1, 2 ],
            ], 2 ]
          ], 2 ],
          [ '_num', 2, 2 ]
        ], 2 ]
      ],

    ].each { |li, ra, tr|

      rad = ra.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
      rad = "#{rad[0, 60]}..." if rad.length > 60
      title = "parses li#{li} `#{rad}`"

      it(title) { expect(Flor::Rad.parse(ra)).to eq(tr) }
    }
  end
end

