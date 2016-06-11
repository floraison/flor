
#
# specifying flor
#
# Tue Feb  2 16:33:43 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'set' do

    it 'has no effect on its own' do

      flon = %{
        set _
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({})
      expect(r['vars'].has_key?('_')).to be(false)
    end

    it 'sequences its children' do

      flon = %{
        set f.a
          0
          1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'a' => 1, 'ret' => nil })
    end

    it 'sets fields' do

      flon = %{
        set f.a
          0
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({})
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => nil })
    end

    it 'sets fields deep' do

      flon = %{
        set f.h.count
          7
      }

      r = @executor.launch(flon, payload: { 'h' => {} })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({})
      expect(r['payload']).to eq({ 'h' => { 'count' => 7 }, 'ret' => nil })
    end

    it 'fails when it cannot set a deep field' do

      flon = %{
        set f.h.i.j
          7
      }

      r = @executor.launch(flon, payload: { 'h' => {} })

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_1')
      expect(r['error']['msg']).to eq("couldn't set field h.i.j")
      expect(r['payload']).to eq({ 'h' => {}, 'ret' => 7 })
    end

    it 'sets variables' do

      flon = %{
        set v.a
          0
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'a' => 0 })
      expect(r['payload']).to eq({ 'ret' => nil })
    end

    it 'sets variables deep' do

      flon = %{
        set v.h.count
          8
      }

      r = @executor.launch(flon, vars: { 'h' => {} })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'h' => { 'count' => 8 } })
      expect(r['payload']).to eq({ 'ret' => nil })
    end

    it 'fails when it cannot set a deep variable' do

      flon = %{
        set v.h.i.j
          9
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_1')
      expect(r['error']['msg']).to eq("couldn't set var v.h.i.j")
      expect(r['payload']).to eq({ 'ret' => 9 })
    end

    it 'leaves f.ret untouched' do

      flon = %{
        11
        set f.a 12
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['a']).to eq(12)
      expect(r['payload']['ret']).to eq(11)
    end

    it 'leaves f.ret unless explicitely setting it' do

      flon = %{
        11
        set f.ret 12
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(12)
    end
  end

  describe 'set a' do

    it 'sets locally if there is no a in the lookup chain' do

      flon = %{
        sequence
          sequence vars: {}
            set a
              1
            push f.l
              a
          push f.l
            a
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['payload']['l']).to eq([ 1 ])
      expect(r['error']['msg']).to eq("don't know how to apply \"a\"")
    end

    it 'overwrites an already set a (locally)' do

      flon = %{
        sequence
          set a
            0
          set a
            1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end

    it 'overwrites an already set a (above)' do

      flon = %{
        sequence
          set a
            0
          sequence vars: {}
            set a
              1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end
  end

  describe 'set v.a' do

    it 'sets locally if there is no a in the lookup chain' do

      flon = %{
        sequence
          sequence vars: {}
            set v.a
              1
            push f.l
              a
          push f.l
            a
      }

      r = @executor.launch(flon, payload: { 'l' => [] })

      expect(r['point']).to eq('failed')
      expect(r['payload']['l']).to eq([ 1 ])
      expect(r['error']['msg']).to eq("don't know how to apply \"a\"")
    end

    it 'overwrites an already set a (locally)' do

      flon = %{
        sequence
          set v.a
            0
          set v.a
            1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end

    it 'overwrites an already set a (above)' do

      flon = %{
        sequence
          set v.a
            0
          sequence vars: {}
            set v.a
              1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end
  end

  describe 'set lv.a' do

    it 'always sets locally' do

      flon = %{
        sequence
          set lv.a
            0
          set b
            10
          set lv.a
            1
          set lv.b
            11
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'a' => 1, 'b' => 11 })
    end
  end

  describe 'setr' do

    it 'sets and return the just set value' do

      flon = %{
        setr f.a
          0
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => 0 })
    end
  end
end

