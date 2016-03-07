
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
          [ '_sym', 'a', 2 ],
          [ '_sym', 'b', 2 ]
        ], 2 ],
        __LINE__
      ],
      [
        %{
          sequence a, vars: 1, timeout: 1h, b
        },
        [ 'sequence', [
          [ '_atts', [
            [ '_sym', 'vars', 2 ], [ '_num', 1, 2 ],
            [ '_sym', 'timeout', 2 ], [ '_sym', '1h', 2 ]
          ], 2 ],
          [ '_sym', 'a', 2 ],
          [ '_sym', 'b', 2 ]
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

