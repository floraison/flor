
#
# specifying flor
#
# Tue Dec 20 16:52:02 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

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

  describe 'on' do

    it 'traps signals' do

      r = @unit.launch(
        %q{
          set l []
          on 'approve'
            push l "$(msg.name)d($(sig))"
          push l 'requested'
          signal 'approve'
          push l 'done.'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq(%w[ requested done. approved(approve) ])
    end

    it 'traps signals and their payload' do

      r = @unit.launch(
        %q{
          set l []
          push l 'a'
          on 'approve'
            push l sig
            push l msg.payload.ret
            push l f.color
          set f.color 'blue'
          signal 'approve'
            'b'
          push l 'c'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq(%w[ a c approve b blue ])
    end

    it 'traps signals by regex' do

      r = @unit.launch(
        %q{
          set l []
          push l 'in'
          on (/^red-.*/)
          #on [ /^red-.*/ ]
            push l sig
          signal 'red-zero'
          signal 'blue-zero'
          signal 'red-one'
          push l 'out'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq(%w[ in red-zero out red-one ])
    end

    it 'traps multiple signals' do

      r = @unit.launch(
        %q{
          set l []
          push l 'in'
          on [ /^bl/ 'red' 'white' ]
            push l sig
          signal 'black'
          signal 'red'
          signal 'green'
          signal 'blue'
          signal 'white'
          push l 'out'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['l']).to eq(%w[ in black red blue out white ])
    end
  end
end

