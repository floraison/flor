
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
      'msg1' => 'hello "le monde"' }
  end

  def lookup(k)

    @h[k]
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

    it "doesn't expand \"a)b\"" do

      expect(@d.expand('a)b')).to eq('a)b')
    end

    it "doesn't expand \"$xxx\"" do

      expect(@d.expand('$xxx')).to eq('$xxx')
    end

    it "doesn't expand \"x$xxx\"" do

      expect(@d.expand('x$xxx')).to eq('x$xxx')
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

      it "understands |s/xx/yy/ (substitution filter)"
    end

    context "filter pipes" do

      it "understands |l>4 (length filter)" do

        expect(@d.expand("$(lazy|l>4||'none)")).to eq("none");
        expect(@d.expand("$(lazy|l<4||'none)")).to eq("dog");

        expect(@d.expand("$(lazy|l<=3||'none)")).to eq("dog");
        expect(@d.expand("$(lazy|l>=3||'none)")).to eq("dog");

        expect(@d.expand("$(lazy|l=3||'none)")).to eq("dog");
        expect(@d.expand("$(lazy|l=4||'none)")).to eq("none");
        expect(@d.expand("$(lazy|l==3||'none)")).to eq("dog");
        expect(@d.expand("$(lazy|l==4||'none)")).to eq("none");

        expect(@d.expand("$(lazy|l!=4||'none)")).to eq("dog");
        expect(@d.expand("$(lazy|l!=3||'none)")).to eq("none");
        expect(@d.expand("$(lazy|l<>4||'none)")).to eq("dog");
        expect(@d.expand("$(lazy|l<>3||'none)")).to eq("none");
      end

      it "understands |m/xx/ (match filter)"
    end
  end
end

