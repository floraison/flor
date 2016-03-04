
#
# specifying flor
#
# Mon Feb 29 15:52:37 JST 2016
#

require 'spec_helper'


describe Flor::Node do

  class Flor::Node
    public :key_split
    public :resolve
  end

  describe '#key_split' do

    it 'splits keys for "normal" variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('a')).to eq([ 'v', '', 'a' ])
      expect(n.key_split('v.a')).to eq([ 'v', '', 'a' ])
    end

    it 'splits keys for local variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('lv.a')).to eq(%w[ v l a ])
    end

    it 'split keys for global variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('gv.a')).to eq(%w[ v g a ])

      expect(n.key_split('g.a')).to eq([ 'v', '', 'g.a' ])
    end

    it 'splits keys for domain variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('dv.a')).to eq(%w[ v d a ])

      expect(n.key_split('d.a')).to eq([ 'v', '', 'd.a' ])
    end

    it 'splits keys for wars' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('w.a')).to eq([ 'w', '', 'a' ])
    end

    it 'splits keys for fields' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('f.a')).to eq([ 'f', '', 'a' ])
    end
  end

  describe '#resolve' do

    before :all do

      exe = { 'nodes' => {} }
      nod = { 'vars' => { 'v0' => 7, 'v1' => 3.1 } }
      msg = nil

      @n = Flor::Node.new(exe, nod, msg)
    end

    it 'leaves a pure value as is' do

      expect(@n.resolve(11)).to eq(11)
      expect(@n.resolve(12.01)).to eq(12.01)
      expect(@n.resolve(true)).to eq(true)
      expect(@n.resolve(false)).to eq(false)
      expect(@n.resolve(nil)).to eq(nil)
    end

    it 'attempts to derefence a symbol' do

      expect(@n.resolve('v0')).to eq(7)
      expect(@n.resolve('v1')).to eq(3.1)
    end

    it 'returns a single quoted string as is' do

      expect(
        @n.resolve([ 'val', { 't' => 'sqstring', 'v' => 'sqs' }, -1, [] ])
      ).to eq(
        'sqs'
      )
    end

    it 'attempts to derefence a dollar expression'

    it 'resolves the elements of an array'
    it 'resolves the entries of an object'
  end
end

