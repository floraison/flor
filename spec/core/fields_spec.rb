
#
# specifying flor
#
# Wed Apr 26 05:42:07 JST 2017
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a field as head' do

    it 'is dereferenced upon application' do

      r = @executor.launch(%q{
          set f.a
            sequence
          #$(f.a)
          f.a
            1
            2
        })

#if r['point'] != 'terminated'
#  puts "-" * 80
#  puts "-" * 80
#  pp r
#  puts "-" * 80
#  puts "-" * 80
#end
      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(2)
    end

    it 'triggers an error when missing' do

      r = @executor.launch(%q{
          f.a
            1
            2
        })

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("don't know how to apply \"f.a\"")
    end

    it 'yields the value if not a proc or a func' do

      r = @executor.launch(
        %q{
          f.a 2
        },
        payload: { 'a' => 1 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end

    it 'accepts a tag' do

      r = @executor.launch(
        %q{
          f.a tag: 'x'
        },
        payload: { 'a' => 1 })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)

      ent = @executor.journal.find { |m| m['point'] == 'entered' }
      lef = @executor.journal.find { |m| m['point'] == 'left' }

      expect(ent['tags']).to eq(%w[ x ])
      expect(lef['tags']).to eq(%w[ x ])
    end
  end

  describe 'a field reference' do

    it 'yields the value' do

      r = @executor.launch(
        %q{
          f.key
        },
        payload: { 'key' => 'c major' })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['key']).to eq('c major')
      expect(r['payload']['ret']).to eq('c major')
    end

    it 'yields null else' do

      r = @executor.launch(%q{
          f.key
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end
  end

  describe 'a field deep reference' do

    it 'yields the desired value' do

      r = @executor.launch(
        %q{
          set f.c f.a.0
          f.a.0.b
        },
        payload: { 'a' => [ { 'b' => 'c' } ] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['c']).to eq({ 'b' => 'c' })
      expect(r['payload']['ret']).to eq('c')
    end

    it 'yields null if not found' do

      r = @executor.launch(%q{
          f.a.0.b
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end

    it 'indexes an array' do

      r = @executor.launch(%q{
          push f.l f.a.0
          push f.l f.a[1,2]
          push f.l f.a[1:5:2]
          push f.l f.a[1;3]
        },
        payload: { 'a' => %w[ a b c d e f ], 'l' => []})

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['l']
      ).to eq([
        'a', %w[ b c ], %w[ b d f ], %w[ b d ]
      ])
    end

    {

      'set f.a false; f.a' => false,
      'set f.a true; f.a' => true,
      'set f.a null; f.a' => nil,
      'set f.a false; [ f.a ]' => [ false ],
      'set f.a true; [ f.a ]' => [ true ],
      'set f.a null; [ f.a ]' => [ nil ],

    }.test_each(self)
  end
end

