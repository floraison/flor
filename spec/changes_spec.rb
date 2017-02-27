
#
# specifying flor
#
# Mon Feb 27 05:55:01 JST 2017
#

require 'spec_helper'


describe Flor::Changes do

  describe '.apply' do

    context '"add"' do

      it 'adds at the root' do

        r = Flor::Changes.apply(
          {},
          [ { 'op' => 'add', 'path' => 'name', 'value' => 'jack' } ])

        expect(r).to eq({
          'name' => 'jack'
        })
      end

      it 'adds to a hash' do

        r = Flor::Changes.apply(
          { 'atts' => {} },
          [ { 'op' => 'add', 'path' => 'atts.age', 'value' => 30 } ])

        expect(r).to eq({
          'atts' => { 'age' => 30 }
        })
      end

      it 'adds to an array' do

        r = Flor::Changes.apply(
          { 'h' => { 'a' => [ 0, 1, 2 ] } },
          [ { 'op' => 'add', 'path' => 'h.a.1', 'value' => 'one' } ])

        expect(r).to eq({
          'h' => { 'a' => [ 0, 'one', 1, 2 ] }
        })
      end
    end

    context '"replace"' do

      it 'replaces at the root' do

        r = Flor::Changes.apply(
          { 'h' => { 'a' => [] } },
          [ { 'op' => 'replace', 'path' => 'h', 'value' => 'hash' } ])

        expect(r).to eq({
          'h' => 'hash'
        })
      end

      it 'replaces in a hash' do

        r = Flor::Changes.apply(
          { 'h' => { 'a' => [] } },
          [ { 'op' => 'replace', 'path' => 'h.a', 'value' => [ 0, 1, 2 ] } ])

        expect(r).to eq({
          'h' => { 'a' => [ 0, 1, 2 ] }
        })
      end

      it 'replaces in an array' do

        r = Flor::Changes.apply(
          { 'h' => { 'a' => [ 0, 1, 2 ] } },
          [ { 'op' => 'replace', 'path' => 'h.a.1', 'value' => 'one' } ])

        expect(r).to eq({
          'h' => { 'a' => [ 0, 'one', 2 ] }
        })
      end
    end

    context '"remove"' do

      it 'removes from the root' do

        r = Flor::Changes.apply(
          { 'name' => 'bill' },
          [ { 'op' => 'remove', 'path' => 'name' } ])

        expect(r).to eq({
        })
      end

      it 'removes from a hash' do

        r = Flor::Changes.apply(
          { 'h' => { 'a' => [ 0, 1, 2 ] } },
          [ { 'op' => 'remove', 'path' => 'h.a' } ])

        expect(r).to eq({
          'h' => {}
        })
      end

      it 'removes from an array' do

        r = Flor::Changes.apply(
          { 'h' => { 'a' => [ 0, 1, 2 ] } },
          [ { 'op' => 'remove', 'path' => 'h.a.1' } ])

        expect(r).to eq({
          'h' => { 'a' => [ 0, 2 ] }
        })
      end
    end
  end
end

