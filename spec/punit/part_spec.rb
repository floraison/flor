
#
# specifying flor
#
# Sat Oct 27 14:27:00 JST 2018
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'forktest'
    #@unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'part' do

    it 'parts' do

      r = @unit.launch(
        %q{
          sequence
            set f.parted
              part
                _skip 4
                trace 'a'
            trace 'b'
          trace 'c'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['parted']).to eq('0_0_0_1')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'b c a'
      )
    end

    it 'may be cancelled explicitely'
    it 'does not get cancelled when its parent gets cancelled'
  end
end

