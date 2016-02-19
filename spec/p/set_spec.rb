
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

      rad = %{
        set
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({})
    end

    it 'sequences its children' do

      rad = %{
        set f.a
          0
          1
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'a' => 1, 'ret' => 1 })
    end

    it 'sets fields' do

      rad = %{
        set f.a
          0
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({})
      expect(r['payload']).to eq({ 'a' => 0, 'ret' => 0 })
    end

    it 'sets fields deep' do

      rad = %{
        set f.h.count
          7
      }

      r = @executor.launch(rad, payload: { 'h' => {} })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({})
      expect(r['payload']).to eq({ 'h' => { 'count' => 7 }, 'ret' => 7 })
    end

    it 'fails when it cannot set a deep field' do

      rad = %{
        set f.h.i.j
          7
      }

      r = @executor.launch(rad, payload: { 'h' => {} })

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_0')
      expect(r['error']['msg']).to eq("couldn't set field h.i.j")
      expect(r['payload']).to eq({ 'h' => {}, 'ret' => 7 })
    end

    it 'sets variables' do

      rad = %{
        set v.a
          0
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'a' => 0 })
      expect(r['payload']).to eq({ 'ret' => 0 })
    end

    it 'sets variables deep' do

      rad = %{
        set v.h.count
          8
      }

      r = @executor.launch(rad, vars: { 'h' => {} })

      expect(r['point']).to eq('terminated')
      expect(r['from']).to eq('0')
      expect(r['vars']).to eq({ 'h' => { 'count' => 8 } })
      expect(r['payload']).to eq({ 'ret' => 8 })
    end

    it 'fails when it cannot set a deep variable' do

      rad = %{
        set v.h.i.j
          9
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('failed')
      expect(r['from']).to eq('0_0')
      expect(r['error']['msg']).to eq("couldn't set var lv.h.i.j")
      expect(r['payload']).to eq({ 'ret' => 9 })
    end
  end
end

