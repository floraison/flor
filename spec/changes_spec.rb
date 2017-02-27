
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

      it 'adds to an array'
    end

    context '"replace"' do

      it 'replaces at the root'
      it 'replaces in a hash'
      it 'replaces in a array'
    end

    context '"remove"' do

      it 'removes from the root' do

        r = Flor::Changes.apply(
          { 'name' => 'bill' },
          [ { 'op' => 'remove', 'path' => 'name' } ])

        expect(r).to eq({
        })
      end

      it 'removes from a hash'
      it 'removes from an array'
    end
  end
end

