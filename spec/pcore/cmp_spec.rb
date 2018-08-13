
#
# specifying flor
#
# Wed Mar  2 20:44:53 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '=' do

    it 'compares strings' do

      r = @executor.launch(
        %q{
          sequence
            push f.l
              =
                "alpha"
                "alpha"
            push f.l
              =
                "alpha"
                "bravo"
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares integers' do

      r = @executor.launch(
        %q{
          sequence
            push f.l
              =
                1
                1
                1
            push f.l
              =
                1
                -1
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares floats' do

      r = @executor.launch(
        %q{
          sequence
            push f.l
              =
                1.0
                1.0
            push f.l
              =
                1.0
                1
            push f.l
              =
                1.0
                1.0000001
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, true, false ])
    end

    it 'compares booleans' do

      r = @executor.launch(
        %q{
          sequence
            push f.l
              =
                true
                true
            push f.l
              =
                false
                false
            push f.l
              =
                true
                false
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, true, false ])
    end

    it 'compares nulls' do

      r = @executor.launch(
        %q{
          sequence
            push f.l
              =
                null
                null
            push f.l
              =
                null
                false
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares arrays' do

      r = @executor.launch(
        %q{
          sequence
            push f.l
              =
                [ 1, 2 ]
                [ 1, 2 ]
            push f.l
              =
                [ 1, 2 ]
                [ 1, 2 ]
                [ 'a' ]
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end

    it 'compares objects' do

      r = @executor.launch(
        %q{
          sequence
            push f.l
              =
                { a: 1, b: 2 }
                { a: 1, b: 2 }
            push f.l
              =
                { a: 1, b: 2 }
                { a: 1, b: 2, c: 3 }
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ true, false ])
    end
  end

  describe '<' do

    it 'compares integers' do

      r = @executor.launch(
        %q{
          push f.l \ < 2 3
          push f.l \ < 3 2
          push f.l \ > 2 3
          push f.l \ > 3 2
          push f.l \ > 3 2 1
          push f.l \ > 3 2 4
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ true, false, false, true, true, false ])
    end

    it 'compares floats' do

      r = @executor.launch(
        %q{
          push f.l (< 2.0 3.0)
          push f.l (< 3 2.0)
          push f.l (> 2.0 3.0)
          push f.l (> 3 2.0)
          push f.l (> 3 2.0 1.0)
          push f.l (> 3 2.0 4.1)
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ true, false, false, true, true, false ])
    end

    it 'compares strings' do

      r = @executor.launch(
        %q{
          push f.l \ < 'aa' 'bb'
          push f.l \ < 'cc' 'bb'
          push f.l \ > 'zz' 'cc' 'bb'
          push f.l \ > 'bb' 'zz'
          push f.l \ > 'zz' 'aa' 'bb'
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['l']).to eq([ true, false, true, false, false ])
    end

    it 'fails when arguments are not comparable' do

      r = @executor.launch(%{ < 'a' 1 })
      expect(r['point']).to eq('failed')

      r = @executor.launch(%{ < 'a' true })
      expect(r['point']).to eq('failed')

      r = @executor.launch(%{ < true true })
      expect(r['point']).to eq('failed')
    end
  end

  describe '<= and >=' do

    {

      '<= 1 2' => true,
      '<= 1 1' => true,
      '<= 2 1' => false,
      '>= 1 2' => false,
      '>= 1 1' => true,
      '>= 2 1' => true,

      '<= "alpha" "alpha"' => true,
      '<= "alpha" "alphab"' => true,
      '<= "bravo" "alpha"' => false,
      '>= "alpha" "alpha"' => true,
      '>= "alpha" "alphab"' => false,
      '>= "bravo" "alpha"' => true,

    }.each do |exp, ret|

      it "#{ret ? 'tru' : 'fls'} (#{exp})" do

        r = @executor.launch(exp)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(ret)
      end
    end

    it 'fails when arguments are not comparable' do

      r = @executor.launch(%{ <= 'a' 1 })
      expect(r['point']).to eq('failed')

      r = @executor.launch(%{ >= 'a' true })
      expect(r['point']).to eq('failed')

      r = @executor.launch(%{ <= true true })
      expect(r['point']).to eq('failed')
    end
  end

  describe '!= and <>' do

    %w[ != <> ].each do |op|

      {

        [ '"alpha"', '"alpha"' ] => false,
        [ '"alpha"', '"bravo"' ] => true,
        [ '1', '1' ] => false,
        [ '1', '"bravo"' ] => true,
        [ 'true', 'true' ] => false,
        [ 'true', 'false' ] => true,

        [ 'true', 1 ] => true,

      }.each do |(a, b), ret|

        it "#{ret ? 'tru' : 'fls'} (#{op} #{a} #{b})" do

          r = @executor.launch(
            %{
              #{op}
                #{a}
                #{b}
            })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(ret)
        end
      end
    end
  end
end

