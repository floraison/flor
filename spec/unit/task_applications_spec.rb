
#
# specifying flor
#
# Wed Jul 20 05:21:41 JST 2016 outake ryoukan
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'a tasker' do

    it 'can be "referred" directly' do

      flon = %{
        alpha
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_task', 'alpha', -1 ]
      )
    end

    it 'can be "applied" directly' do

      flon = %{
        alpha _
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('alpha')
      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'].first[0]).to eq('alpha')
      expect(r['payload']['seen'].first[1]).to eq('AlphaTasker')
    end

    it 'passes attributes' do

      flon = %{
        alpha a: 0, b: 1
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload'].keys).to eq(%w[ ret seen ])
      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'].first[3]['atts']).to eq({ 'a' => 0, 'b' => 1 })
    end

    it 'preserves "atts"' do

      flon = %{
        set f.atts { a: 0, b: -1, c: 2 }
        alpha a: 0, b: 1, d: 3
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload'].keys).to eq(%w[ ret atts seen ])

      expect(r['payload']['atts']
        ).to eq({ 'a' => 0, 'b' => -1, 'c' => 2 })
      expect(r['payload']['seen'].size
        ).to eq(1)
      expect(r['payload']['seen'].first[3]['atts']
        ).to eq({ 'a' => 0, 'b' => 1, 'd' => 3 })
    end

    it 'respects postfix conditionals' do

      flon = %{
        set i 1
        alpha x: 0 if i == 0
        alpha x: 1 if i == 1
        alpha x: 2 unless i == 2
      }

      r = @unit.launch(flon, wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['seen'].collect(&:last)
      ).to eq([
        { 'ret' => 'alpha', 'atts' => { 'x' => 1 } },
        { 'ret' => 'alpha', 'atts' => { 'x' => 2 } }
      ])
    end
  end
end

