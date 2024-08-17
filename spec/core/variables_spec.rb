
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

    it 'is dereferenced upon application' do

      r = @executor.launch(%{
          set a
            sequence
          a
            1
            2
        })

      expect(r).to have_terminated_as_point
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

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq(1)
    end

    it 'yields the value if not a proc or a func (null)'# do
#
#      r = @executor.launch(%{
#          set a null
#          a 2
#        })
#
#      expect(r).to have_terminated_as_point
#      expect(r['payload']['ret']).to eq(nil)
#    end

    it 'accepts a tag' do

      r = @executor.launch(
        %{
          a tag: 'x'
        },
        vars: { 'a' => 1 })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq(1)

      ent = @executor.journal.find { |m| m['point'] == 'entered' }
      lef = @executor.journal.find { |m| m['point'] == 'left' }

      expect(ent['tags']).to eq(%w[ x ])
      expect(lef['tags']).to eq(%w[ x ])
    end
  end

  describe 'a variable as head (deep)' do

    it 'is dereferenced upon application' do

      r = @executor.launch(%{
          set a { b: sequence }
          a.b
            1
            2
        })

      expect(r).to have_terminated_as_point
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

      expect(r).to have_terminated_as_point
      expect(r['vars']['key']).to eq('a major')
      expect(r['payload']['ret']).to eq([ 'a major' ] * 2)
    end

    it 'fails else' do

      r = @executor.launch(%{
          key
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("cannot find \"key\"")
    end

    it 'fails if a missing variable is the head' do

      r = @executor.launch(
        %q{
          v.a _
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("don't know how to apply \"v.a\"")
    end

    it 'fails if the variable is missing' do

      r = @executor.launch(
        %q{
          v.a
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('variable "a" not found')
    end

    {

      'set a false; v.a' => false,
      'set a true; v.a' => true,
      'set a null; v.a' => nil,
      'set a false; a' => false,
      'set a true; a' => true,
      'set a null; a' => nil,
      'set a false; [ a ]' => [ false ],
      'set a true; [ a ]' => [ true ],
      'set a null; [ a ]' => [ nil ],

    }.test_each(self)
  end

  describe 'a variable deep reference' do

    it 'yields the desired value' do

      r = @executor.launch(
        %{
          set c a.0
          a.0.b
        },
        vars: { 'a' => [ { 'b' => 'c' } ] })

      expect(r).to have_terminated_as_point
      expect(r['vars']['c']).to eq({ 'b' => 'c' })
      expect(r['payload']['ret']).to eq('c')
    end

    it 'yields null when the container exists' do

      r = @executor.launch(
        %{
          [ a.0, h.k0 ]
        },
        vars: { 'a' => [], 'h' => {} })

      expect(r).to have_terminated_as_point
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

      expect(r).to have_terminated_as_point

      expect(r['payload']['l']).to eq([
        'a', %w[ b c ], %w[ a c e ], %w[ c e ] ])
    end

    it 'is OK with if/unless postfix' do

      r = @executor.launch(
        %q{
          push f.l launcher.role
          push f.l 0 unless launcher.role == 'psp'
          push f.l 1 if launcher.role == 'psp'
        },
        vars: { 'launcher' => { 'id' => 1234, 'role' => 'psp' } },
        payload: { 'l' => [] })

      expect(r).to have_terminated_as_point

      expect(r['payload']['l']).to eq([ 'psp', 1 ])
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

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ 0_0_1 0_1_1_0_0_0 _ref _ref ])
    end
  end

  describe 'the "exe" pseudo-variable' do

    it 'gives access to the node' do

      r = @executor.launch(
        %{
          set f.nid node.nid
          set f.exid exe.exid
          set f.domain exe.domain
          set f.counters exe.counters
          set f.node_count (length exe.nodes)
          set f.start execution.start
        })
        #domain: 'gevrey_chambertin')

      expect(r).to have_terminated_as_point

      n = Time.now.utc

      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['nid']).to eq('0_0_1')
      expect(r['payload']['exid']).to eq(r['exid'])
      expect(r['payload']['domain']).to eq(Flor.domain(r['exid']))
      expect(r['payload']['counters']).to eq({ 'msgs' => 58 })
      expect(r['payload']['node_count']).to eq(3)
      expect(r['payload']['start']).to match(/\A#{n.year}-[^ ]+\dZ/)
    end
  end

  describe 'aliasing variables' do

    it 'works' do

      r = @executor.launch(
        %q{
          setr a [ 0 1 2 3 ]
          set f.l0 (length a)
          set olength length
          define length \ -1
          set f.l1 (length a)
          set f.l2 (olength a)
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l0']).to eq(4)
      expect(r['payload']['l1']).to eq(-1)
      expect(r['payload']['l2']).to eq(4)
    end
  end

  describe 'global variables' do

    they 'are optionally prefixed with gv.' do

      r = @executor.launch(
        %q{
          set a 1
          define f a
            [ gv.a, gvar.a, a ]
          f 2
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 1, 1, 2 ])
    end

    they 'may be set directly from child scopes' do

      r = @executor.launch(
        %q{
          set a 1
          define f x
            set a x + 1
            set gv.a x + 2 + a
          f 2
        })

      expect(r).to have_terminated_as_point
      expect(r['vars']['a']).to eq(7)
      expect(r['payload']['ret']).to eq(2)
    end
  end
end

