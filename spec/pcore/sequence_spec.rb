
#
# specifying flor
#
# Sat Jan  9 07:20:32 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'sequence' do

    it 'returns immediately if empty' do

      r = @executor.launch(%q{ sequence _ })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({})
    end

    it 'chains children' do

      r = @executor.launch(
        %q{
          sequence
            set f.a
              0
            set f.b
              1
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'a' => 0, 'b' => 1, 'ret' => nil })
    end

    it 'returns the value of last child as $(ret)' do

      r = @executor.launch(
        %q{
          sequence
            1
            2
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 2 })
    end

    it 'keeps track of its children' do

      r = @executor.launch(
        %q{
          sequence
            0
            stall _
        })

      expect(r).to eq(nil)

      n = @executor.execution['nodes']['0']

      expect(n['cnodes']).to eq(%w[ 0_1 ])
    end

    it 'turns lonely att string results to tags' do

      r = @executor.launch(
        %q{
          sequence 'phase one'
            1
          sequence tags: [ 'phase two', 'intermediate' ] # counter-example
            2
          sequence 'phase three'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('phase three')

      expect(
        @executor.journal
          .select { |m| %w[ entered left ].include?(m['point']) }
          .collect { |m| "#{m['point']}:#{m['tags'].join(',')}" }
      ).to eq([
        'entered:phase one', 'left:phase one',
        'entered:phase two,intermediate', 'left:phase two,intermediate',
        'entered:phase three', 'left:phase three',
      ])
    end

    it 'can be aliased' do

      r = @executor.launch(
        %q{
          set block sequence
          set then sequence
          set else sequence

          set f.l []
          push f.l 'a'
          block
            push f.l 'b'
            push f.l 'c'
          if (length f.l) > 10
            then
              push f.l 'd'
              push f.l 'e'
            else
              push f.l 'f'
              push f.l 'g'
          if (length f.l) > 1
            then
              push f.l 'h'
              push f.l 'i'
            else
              push f.l 'j'
              push f.l 'k'
          push f.l 'l'
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ a b c f g h i l ])
    end
  end
end

