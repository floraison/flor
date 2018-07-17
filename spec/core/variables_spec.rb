
#
# specifying flor
#
# Thu Mar 31 16:17:39 JST 2016
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a variable as head' do

    it 'is derefenced upon application' do

      r = @executor.launch(%{
          set a
            sequence
          a
            1
            2
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end

    it 'triggers an error when missing' do

      r = @executor.launch(%{
          a
            1
            2
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("don't know how to apply \"a\"")
    end

    it 'yields the value if not a proc or a func' do

      r = @executor.launch(%{
          set a 1
          a 2
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end

    it 'yields the value if not a proc or a func (null)'# do
#
#      r = @executor.launch(%{
#          set a null
#          a 2
#        })
#
#      expect(r['point']).to eq('terminated')
#      expect(r['payload']['ret']).to eq(nil)
#    end

    it 'accepts a tag' do

      r = @executor.launch(
        %{
          a tag: 'x'
        },
        vars: { 'a' => 1 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)

      ent = @executor.journal.find { |m| m['point'] == 'entered' }
      lef = @executor.journal.find { |m| m['point'] == 'left' }

      expect(ent['tags']).to eq(%w[ x ])
      expect(lef['tags']).to eq(%w[ x ])
    end
  end

  describe 'a variable as head (deep)' do

    it 'is derefenced upon application' do

      r = @executor.launch(%{
          set a { b: sequence }
          a.b
            1
            2
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end
  end

  describe 'a variable reference' do

    it 'yields the value' do

      r = @executor.launch(
        %{
          [ key, v.key ]
        },
        vars: { 'key' => 'a major' })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['key']).to eq('a major')
      expect(r['payload']['ret']).to eq([ 'a major' ] * 2)
    end

    it 'fails else' do

      r = @executor.launch(%{
          key
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("don't know how to apply \"key\"")
    end

      # not super sure about this one
      # regular interpreters fail on this one
      # limiting this behaviour to fields is better, probably
      #
    it 'yields null if referenced with a v. prefix'# do
#
#      r = @executor.launch(
#        %q{
#          v.a
#        })
#
#      expect(r['point']).to eq('terminated')
#      expect(r['payload']['ret']).to eq(nil)
#    end
  end

  describe 'a variable deep reference' do

    it 'yields the desired value' do

      r = @executor.launch(
        %{
          set c a.0
          a.0.b
        },
        vars: { 'a' => [ { 'b' => 'c' } ] })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['c']).to eq({ 'b' => 'c' })
      expect(r['payload']['ret']).to eq('c')
    end

    it 'yields null when the container exists' do

      r = @executor.launch(
        %{
          [ a.0, h.k0 ]
        },
        vars: { 'a' => [], 'h' => {} })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ nil, nil ])
    end

    it 'fails when the container does not exist' do

      r = @executor.launch(%q{ a.0 })

      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('KeyError')
      expect(r['error']['msg']).to eq('variable "a" not found')
    end

    it 'fails when the container does not exist (deeper)' do

      r = @executor.launch(
        %q{ h.a.0 },
        vars: { 'h' => {} })

      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('KeyError')
      expect(r['error']['msg']).to eq('variable "a" not found at "h"')
    end

    it 'fails when type error' do

      r = @executor.launch(
        %q{ a.k },
        vars: { 'a' => [] })

      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('TypeError')
      expect(r['error']['msg']).to eq('no key "k" for Array at "a"')
        # error straight out of the 'dense' library
    end

    it 'indexes an array' do

      r = @executor.launch(
        %q{
          push f.l f.a.0
          push f.l f.a[1,2]
          push f.l f.a[:7:2]
          push f.l f.a[2;4] # TODO
        },
        payload: { 'a' => %w[ a b c d e f ], 'l' => []})

      expect(r['point']).to eq('terminated')

      expect(r['payload']['l']).to eq([
        'a', %w[ b c ], %w[ a c e ], %w[ c e ] ])
    end
  end

  describe 'the "node" pseudo-variable' do

    it 'gives access to the node' do

      r = @executor.launch(
        %{
          push f.l node.nid
          push f.l "$(node.nid)"
          push f.l node.heat0
          push f.l "$(node.heat0)"
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq(%w[ 0_0_1 0_1_1_0_0 _ref _ref ])
    end
  end
end

