
#
# specifying flor
#
# Mon Feb 29 15:52:37 JST 2016
#

require 'spec_helper'


describe Flor::Node do

  class Flor::Node
    public :key_split
  end

  describe '#key_split' do

    it 'splits keys for "normal" variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('a')).to eq(%w[ v n a ])
      expect(n.key_split('v.a')).to eq(%w[ v n a ])
    end

    it 'splits keys for local variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('lv.a')).to eq(%w[ v l a ])
    end

    it 'split keys for global variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('gv.a')).to eq(%w[ v g a ])

      expect(n.key_split('g.a')).to eq(%w[ v n g.a ])
    end

    it 'splits keys for domain variables' do

      n = Flor::Node.new(nil, nil, nil)

      expect(n.key_split('dv.a')).to eq(%w[ v d a ])

      expect(n.key_split('d.a')).to eq(%w[ v n d.a ])
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
end

