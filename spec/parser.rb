
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
        [ 'number', 1, 1 ],
        __LINE__
      ],
      [
        %{ 11.01 },
        [ 'number', 11.01, 1 ],
        __LINE__
      ],
      [
        %{ true },
        [ 'boolean', true, 1 ],
        __LINE__
      ],
      [
        %{ false },
        [ 'boolean', false, 1 ],
        __LINE__
      ],
      [
        %{ null },
        [ 'null', nil, 1 ],
        __LINE__
      ],
      [
        %{ abc },
        [ 'abc', [], 1 ],
        __LINE__
      ],
      [
        %{ 'def' },
        [ 'sqstring', 'def', 1 ],
        __LINE__
      ],
      [
        %{ "ghi" },
        [ 'dqstring', 'ghi', 1 ],
        __LINE__
      ],
      [
        %{ /jkl/i },
        [ 'rxstring', '/jkl/i', 1 ],
        __LINE__
      ],
    ].each { |ra, tr, li|

      rad = ra.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
      rad = "#{rad[0, 60]}..." if rad.length > 60
      title = "parses li#{li} `#{rad}`"

      it(title) { expect(Flor::Rad.parse(ra)).to eq(tr) }
    }
  end

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
          [ 'symbol', 'a', 2 ],
          [ 'symbol', 'b', 2 ]
        ], 2 ],
        __LINE__
      ],
      [
        %{
          sequence a, vars: 1, timeout: 1h, b
        },
        [ 'sequence', [
          [ 'attributes', [
            [ 'symbol', 'vars', 2 ], [ 'number', 1, 2 ],
            [ 'symbol', 'timeout', 2 ], [ 'symbol', '1h', 2 ]
          ], 2 ],
          [ 'symbol', 'a', 2 ],
          [ 'symbol', 'b', 2 ]
        ], 2 ],
        __LINE__
      ],

    ].each { |ra, tr, li|

      rad = ra.strip.gsub(/\n/, '\n').gsub(/ +/, ' ')
      rad = "#{rad[0, 60]}..." if rad.length > 60
      title = "parses li#{li} `#{rad}`"

      it(title) { expect(Flor::Rad.parse(ra)).to eq(tr) }
    }
  end
end

