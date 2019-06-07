# encoding: UTF-8

#
# specifying flor
#
# Sun Feb  7 14:27:04 JST 2016
#

require 'spec_helper'


describe Flor do

  describe '.decolour(s)' do

    it 'removes colour codes' do

      c = Flor.colours
      s = c.dg('nothing') + ' ' + c.yl('surf')

      expect(s).to eq("\e[90mnothing\e[0;9m \e[33msurf\e[0;9m")
      expect(Flor.decolour(s)).to eq('nothing surf')
    end
  end

  describe '.nocolour_length(s)' do

    it 'returns the string length, escape code put aside' do

      c = Flor.colours; s = c.dg('tribu') + ' ' + c.yl('dana')

      expect(Flor.bw_length(s)).to eq(10)
    end
  end

  describe '.truncate_string(s, l)' do

    it 'truncates' do

      c = Flor.colours; s = c.dg('tribu') + ' de ' + c.yl('dana')

      #(0..Flor.no_colour_length(s) + 1).each do |i|
      #  puts Flor.truncate_string(s, i)
      #end
      expect(Flor.truncate_string(s, 7)).to eq("\e[90mtribu\e[0;9m d...")
      expect(Flor.truncate_string(s, 6)).to eq("\e[90mtribu\e[0;9m ...")
      expect(Flor.truncate_string(s, 5)).to eq("\e[90mtribu...")
      expect(Flor.truncate_string(s, 4)).to eq("\e[90mtrib...")
    end

    it 'truncates (no colours)' do

      s = 'tribut à César'

      expect(Flor.truncate_string(s, 8)).to eq('tribut à...')
    end
  end

  describe '.truncate_string(s, l, "<<<")' do

    it 'truncates' do

      c = Flor.colours; s = c.dg('tribu') + ' de ' + c.yl('dana')

      expect(Flor.truncate_string(s, 7, '<<<')).to eq("\e[90mtribu\e[0;9m d<<<")
    end

    it 'truncates (no colours)' do

      s = 'tribut à César'

      expect(Flor.truncate_string(s, 8, '<<<')).to eq('tribut à<<<')
    end
  end

  describe '.truncate_string(s, l, proc)' do

    it 'truncates' do

      c = Flor.colours; s = c.dg('tribu') + ' de ' + c.yl('dana')

      expect(
        Flor.truncate_string(s, 7, Proc.new { |x, y, z| [ x, y, z ].inspect })
      ).to eq(
        "\e[90mtribu\e[0;9m d[13, 7, \"\\e[90mtribu\\e[0;9m de " +
        "\\e[33mdana\\e[0;9m\"]"
      )
      expect(
        Flor.truncate_string(s, 7, Proc.new { |x| "... (L#{x})" })
      ).to eq(
        "\e[90mtribu\e[0;9m d... (L13)"
      )
    end

    it 'truncates (no colours)' do

      s = 'tribut à César'

      expect(
        Flor.truncate_string(s, 8, Proc.new { |x| "... (L#{x})" })
      ).to eq('tribut à... (L14)')
    end
  end

  describe '.tstamp' do

    it 'returns the current timestamp' do

      expect(
        Flor.tstamp
      ).to match(
        /\A#{Time.now.utc.year}-\d\d-\d\dT\d\d:\d\d:\d\d.\d{6}Z\z/
      )
    end

    it 'turns a Time instance into a String timestamp' do

      t = Time.utc(2015, 12, 19, 13, 30, 00)

      expect(Flor.tstamp(t)).to eq('2015-12-19T13:30:00.000000Z')
    end

    it 'turns a Time instance into a String timestamp' do

      t = Time.utc(2017, 1, 1, 8, 16, 00)

      expect(Flor.tstamp(t)).to eq('2017-01-01T08:16:00.000000Z')
    end
  end

  describe '.true?' do

    it 'returns true when the argument is true for Flor' do

      expect(Flor.true?(1)).to eq(true)
      expect(Flor.true?(true)).to eq(true)
    end

    it 'returns false when the argument else' do

      expect(Flor.true?(nil)).to eq(false)
      expect(Flor.true?(false)).to eq(false)
    end
  end

  describe '.false?' do

    it 'returns true when the argument is false for Flor' do

      expect(Flor.false?(nil)).to eq(true)
      expect(Flor.false?(false)).to eq(true)
    end

    it 'returns false when the argument else' do

      expect(Flor.false?(1)).to eq(false)
      expect(Flor.false?(true)).to eq(false)
    end
  end

  describe '.is_sub_domain?(d, s)' do

    it 'fails if d is not a domain' do

      expect {
        Flor.is_sub_domain?('.test.x', 'y')
      }.to raise_error(ArgumentError, "not a domain \".test.x\"")
    end

    it 'fails if s is not a domain' do

      expect {
        Flor.is_sub_domain?('test.x', '.test.x.y')
      }.to raise_error(ArgumentError, "not a sub domain \".test.x.y\"")
    end

    it 'returns false if s is not a sub domain of d' do

      expect(Flor.is_sub_domain?('test.x', 'test.y')).to eq(false)
    end

    it 'returns true if it is' do

      expect(Flor.is_sub_domain?('test.x', 'test.x')).to eq(true)
      expect(Flor.is_sub_domain?('test.x', 'test.x.y')).to eq(true)
    end
  end

  describe '.potential_domain_name?' do

    [
      [ 1234, false ],
      [ 'net.ntt-u-20170915.0405.pukotsetibi', false ],
      [ 'net.ntt', true ],
    ].each do |o, r|

      it "returns #{r} for #{o.inspect}" do

        expect(Flor.potential_domain_name?(o)).to eq(r)
      end
    end
  end

#  describe '.potential_exid?' do
#
#    [
#      [ 1234, false ],
#      [ 'net.ntt-u-20170915.0405.pukotsetibi', true ],
#    ].each do |o, r|
#
#      it "returns #{r} for #{o.inspect}" do
#
#        expect(Flor.potential_exid?(o)).to eq(r)
#      end
#    end
#  end

  describe '.parent_tree_locate(t, nid)' do

    before :all do

      @t = Flor.parse(
        %q{
          sequence
            alpha
            concurrence
              bravo
              charly
        })
    end

    it 'locates nil when tree is nil' do

      t, i = Flor.parent_tree_locate(nil, '0_0')
      expect([ t, i ]).to eq([ nil, nil ])
    end

    it 'locates 0' do

      t, i = Flor.parent_tree_locate(@t, '0')
      expect([ t[0], i ]).to eq([ 'sequence', nil ])
    end

    it 'locates 0_0' do

      t, i = Flor.parent_tree_locate(@t, '0_0')
      expect([ t[0], i ]).to eq([ 'sequence', 0 ])
    end

    it 'locates 0_1' do

      t, i = Flor.parent_tree_locate(@t, '0_1')
      expect([ t[0], i ]).to eq([ 'sequence', 1 ])
    end

    it 'locates 0_1_1' do

      t, i = Flor.parent_tree_locate(@t, '0_1_1')
      expect([ t[0], i ]).to eq([ 'concurrence', 1 ])
    end

    it 'does not locate 0_2_1' do

      t, i = Flor.parent_tree_locate(@t, '0_2_1')
      expect([ t, i ]).to eq([ nil, nil ])
    end
  end

  describe '.tree_locate(t, nid)' do

    it 'locates' do

      t = Flor.parse(
        %q{
          sequence
            alpha
            concurrence
              bravo
              charly
        })

      expect(Flor.tree_locate(t, '0_2')).to eq(nil)

      expect(Flor.tree_locate(t, '0')[0]).to eq('sequence')
      expect(Flor.tree_locate(t, '0_0')[0]).to eq('alpha')
      expect(Flor.tree_locate(t, '0_1')[0]).to eq('concurrence')
      expect(Flor.tree_locate(t, '0_1_1')[0]).to eq('charly')
    end
  end

  describe '.extract_exid_and_nid(s)' do

    it 'returns nil if s does not hold a exid-nid' do

      expect(Flor.extract_exid_and_nid('x')).to eq(nil)
    end

    it 'returns [ exid, nid ]' do

      expect(
        Flor.extract_exid_and_nid(
          'task-shell-cli-20170221.0029.fuchemowabe-0_1_1.json')
      ).to eq(%w[
        20170221.0029.fuchemowabe 0_1_1
      ])
    end

    it 'returns [ exid, nid ] (when subnid)' do

      expect(
        Flor.extract_exid_and_nid(
          'task-shell-cli-20170221.0029.fuchemowabe-0_1_1-1.json')
      ).to eq(%w[
        20170221.0029.fuchemowabe 0_1_1-1
      ])
    end
  end

  describe '.relativize_path(path, from)' do

    it 'relativizes paths' do

      expect(
        Flor.relativize_path(
          File.absolute_path('spec'))
      ).to eq(
        'spec'
      )

      expect(
        Flor.relativize_path(
          File.absolute_path('spec'), File.absolute_path('spec'))
      ).to eq(
        '.'
      )
    end
  end

  describe '.point?' do

    it 'returns true if the argument is a point' do

      expect(Flor.point?('execute')).to eq(true)
      expect(Flor.point?('task')).to eq(true)
    end

    it 'returns false if the argument is not a point' do

      expect(Flor.point?(1)).to eq(false)
      expect(Flor.point?('nada')).to eq(false)
    end
  end

  describe '.const_lookup' do

    it 'returns a class given a string' do

      expect(
        Flor.const_lookup('Flor::Pro::Collect')
      ).to eq(
        Flor::Pro::Collect
      )
    end

    it 'fails if it does not find' do

      expect {
        Flor.const_lookup('Very::Nada')
      }.to raise_error(
        NameError, /\Auninitialized constant (Kernel::)?Very/
      )
    end

    it 'does not stray' do

      class ::WhateverOut < Flor::Logger::Out; end

      expect {
        Flor.const_lookup('Flor::WhateverOut')
      }.to raise_error(
        NameError, /\Auninitialized constant Flor::WhateverOut/
      )
    end
  end

  describe '.is_regex_string?' do

    [

      [ '/a/', true ],
      [ 'a', false ],

    ].each do |string, result|

      it "returns #{result} for #{string.inspect}" do

        expect(Flor.is_regex_string?(string)).to eq(result)
      end
    end
  end

  describe '.to_regex' do

    [

      [ '/car/', /car/ ],
      [ '/\Acar/i', /\Acar/i ],
      [ '/car', /\/car/ ],

    ].each do |serialized, regex|

      it "turns #{serialized.inspect} back to #{regex.inspect}" do

        r = Flor.to_regex(serialized)

        expect(r.class).to eq(Regexp)
        expect(r.to_s).to eq(regex.to_s)

        expect(r).to eq(regex) if RUBY_VERSION >= '2'
      end
    end
  end

  describe '.deep_merge' do

    [
      [
        [ 1, 2 ],
        [ 1, 3, 4 ],
        # ==>
        [ 1, 3, 4 ]
      ],
      [
        { h: { a: 0 }, a: [ 0, { c: 3 } ] },
        { h: { b: 1 }, a: [ :one, { d: 4 }, 2 ] },
        # ==>
        { h: { a: 0, b: 1 }, a: [ :one, { c: 3, d: 4 }, 2 ] }
      ],
    ].each do |a, b, result|

      it "merges #{a.inspect} and #{b.inspect}" do

        expect(
          Flor.deep_merge(a, b)
        ).to eq(
          result
        )
      end
    end
  end

#  describe '.tree_to_floor' do
#
#    {
#
#      '1' =>
#        '1',
#      'stall _' =>
#        'stall _',
#      'task "bob"' =>
#        'task "bob"',
#      'task "bob" tag: "nada"' =>
#        'task "bob" tag: "nada"',
#      'sequence \ a 1; b _' =>
#        %{
#          sequence
#            a 1
#            b _
#        }.itrim
#
#    }.each do |source, target|
#
#      chop = false
#      source, chop = *source if source.is_a?(Array)
#
#      st = Flor.parse(source)
#
#      title = "turns #{st.inspect} to #{target.inspect}"
#      title += " (chop: true)" if chop
#
#      it(title) do
#
#        opts = chop ? { chop: chop } : {}
#
#        expect(Flor.tree_to_flor(st, opts)).to eq(target)
#      end
#    end
#  end
end

