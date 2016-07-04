
#
# specifying flor
#
# Sat Dec 12 07:05:15 JST 2015
#

require 'spec_helper'


class SpecDollar < Flor::Dollar

  def initialize

    @h = {
      'brown' => 'fox',
      'lazy' => 'dog',
      'quick' => 'jump',
      'l' => 'la',
      'z' => 'zy',
      'black' => 'PuG',
      'func' => 'u',
      'ba' => 'black adder',
      'bs' => 'bLACK shEEp',
      'msg' => '"hello world"',
      'msg1' => 'hello "le monde"',
      'arr' => [ 1, 2, 3 ],
      'hsh' => { 'a' => 'A', 'b' => 'B' } }
  end

  def lookup(k)

    key, pth = k.split('.', 2)
    pth ? Flor.deep_get(@h[key], pth)[1] : @h[key]
  end
end


describe Flor::Dollar do

  describe '#expand' do

    before :each do

      @d = SpecDollar.new
    end

    it 'does not expand if not necessary' do

      expect(
        @d.expand('quick brown fox')
      ).to eq(
        'quick brown fox'
      )
    end

    it 'expands "$(brown)"' do

      expect(
        @d.expand('$(brown)')
      ).to eq(
        'fox'
      )
    end

    it 'expands ".$(brown)."' do

      expect(
        @d.expand('.$(brown).')
      ).to eq(
        '.fox.'
      )
    end

    it 'expands "$(brown) $(lazy)"' do

      expect(
        @d.expand('$(brown) $(lazy)')
      ).to eq(
        'fox dog'
      )
    end

    it 'expands "$($(l)$(z))"' do

      expect(
        @d.expand('$($(l)$(z))')
      ).to eq(
        'dog'
      )
    end

    it "expands to a blank string if it doesn't find" do

      expect(
        @d.expand('<$(blue)>')
      ).to eq(
        '<>'
      )
    end

    it 'expands $(arr)' do

      expect(@d.expand('$(arr)')).to eq([ 1, 2, 3 ])
    end

    it 'expands $(hsh)' do

      expect(@d.expand('$(hsh)')).to eq({ 'a' => 'A', 'b' => 'B' })
    end

    it 'expands "a$(arr)z"' do

      expect(@d.expand('a$(arr)z')).to eq('a[1,2,3]z')
    end

    it 'expands "a$(hsh)z"' do

      expect(@d.expand('a$(hsh)z')).to eq('a{"a":"A","b":"B"}z')
    end

    it "doesn't expand \"a)b\"" do

      expect(@d.expand('a)b')).to eq('a)b')
    end

    it "doesn't expand \"$xxx\"" do

      expect(@d.expand('$xxx')).to eq('$xxx')
    end

    it "doesn't expand \"x$xxx\"" do

      expect(@d.expand('x$xxx')).to eq('x$xxx')
    end

    it "doesn't expand \"^[bct]ar$\"" do

      expect(@d.expand('^[bct]ar$')).to eq('^[bct]ar$')
    end

    context 'init single quote' do

      it "doesn't expand \"$(nada||'$xxx)\"" do

        expect(@d.expand("$(nada||'$xxx)")).to eq('$xxx')
      end

      it 'accepts an escaped )' do

        expect(@d.expand("$(nada||'su\\)rf)")).to eq('su)rf')
      end

      it 'accepts an escaped ) (deeper)' do

        expect(@d.expand("$(a||'$(nada||'su\\)rf))")).to eq('su)rf')
      end

      it 'accepts an escaped $' # ?
    end

    context 'pipes' do

      it 'understands || (or)' do

        expect(@d.expand('$(blue||brown)')).to eq('fox')
      end

      it 'understands |r (reverse)' do

        expect(@d.expand('$(brown|r)')).to eq('xof')
      end

      it "understands |u (uppercase)" do

        expect(@d.expand("$(brown|u)")).to eq("FOX")
      end

      it "understands |u|r" do

        expect(@d.expand("$(brown|u|r)")).to eq("XOF")
      end

      it "understands |d (downcase)" do

        expect(@d.expand("$(black|d)")).to eq("pug")
      end

      it "understands |1..-1" do

        expect(@d.expand("$(quick|1..-1)")).to eq("ump")
      end

      it "understands |1,2" do

        expect(@d.expand("$(quick|1,2)")).to eq("um")
      end

      it "understands |2" do

        expect(@d.expand("$(quick|2)")).to eq("m")
      end

      it "understands |-3" do

        expect(@d.expand("$(quick|-3)")).to eq("u")
      end

      it "understands ||'text" do

        expect(@d.expand("$(nada||'text|u)")).to eq("TEXT")
      end

      it "understands |c (capitalize)" do

        expect(@d.expand("$(ba|c)")).to eq("Black Adder")
        expect(@d.expand("$(bs|c)")).to eq("Black Sheep")
      end

      it "understands |q ([double] quote)" do

        expect(@d.expand("the $(ba|c|q)")).to eq("the \"Black Adder\"")
        expect(@d.expand("the $(bs|c|q)")).to eq("the \"Black Sheep\"")
      end

      it "doesn't double quote when |q" do

        expect(@d.expand("$(msg|q)")).to eq("\"hello world\"")
      end

      it "double quotes when |Q" do

        expect(@d.expand("$(msg|Q)")).to eq("\"\\\"hello world\\\"\"")
      end

      it "escapes when |q" do

        expect(@d.expand("$(msg1|q)")).to eq("\"hello \\\"le monde\\\"\"")
      end

      it "understands |s/xx/yy/ (substitution filter)" do

        expect(@d.expand("$(brown|s/black/blue/)")).to eq('fox')
        expect(@d.expand("$(ba|s/a/o/)")).to eq('block adder')
        expect(@d.expand("$(ba|s/a/o/g)")).to eq('block odder')
        expect(@d.expand("$(ba|s/A/O/gi)")).to eq('blOck Odder')
      end
    end

    context "filter pipes" do

      it "understands |l>4 (length filter)" do

        expect(@d.expand("$(lazy|l>4||'none)")).to eq("none")
        expect(@d.expand("$(lazy|l<4||'none)")).to eq("dog")

        expect(@d.expand("$(lazy|l<=3||'none)")).to eq("dog")
        expect(@d.expand("$(lazy|l>=3||'none)")).to eq("dog")

        expect(@d.expand("$(lazy|l=3||'none)")).to eq("dog")
        expect(@d.expand("$(lazy|l=4||'none)")).to eq("none")
        expect(@d.expand("$(lazy|l==3||'none)")).to eq("dog")
        expect(@d.expand("$(lazy|l==4||'none)")).to eq("none")

        expect(@d.expand("$(lazy|l!=4||'none)")).to eq("dog")
        expect(@d.expand("$(lazy|l!=3||'none)")).to eq("none")
        expect(@d.expand("$(lazy|l<>4||'none)")).to eq("dog")
        expect(@d.expand("$(lazy|l<>3||'none)")).to eq("none")
      end

      it "understands |m/xx/ (match filter)" do

        expect(@d.expand("$(brown|m/black/||'none)")).to eq('none')
        expect(@d.expand("$(ba|m/black/||'none)")).to eq('black adder')
      end
    end

    context 'builtin' do

      before :each do

        @x =
          Flor::Node::Expander.new(
            Flor::Node.new(
              { 'exid' => 'eval-u0-20160226.1807.bowageyiba',
                'nodes' => {} }, # execution
              { 'nid' => '0_0-7' }, # node
              nil)) # message
      end

      it 'understands $(nid)' do

        expect(@x.expand("$(nid)")).to eq('0_0-7')
      end

      it 'understands $(exid)' do

        expect(@x.expand("$(exid)")).to eq('eval-u0-20160226.1807.bowageyiba')
      end

      it 'understands $(tstamp)' do

        expect(@x.expand("$(tstamp)")).to match(/\A2\d{3}\d{4}\.\d+u\z/)
      end
    end

    context 'index' do

      it 'indexes arrays' do

        expect(@d.expand('$(arr.1)')).to eq(2)
      end

      it 'indexes objects' do

        expect(@d.expand('$(hsh.b)')).to eq('B')
      end
    end
  end
end

