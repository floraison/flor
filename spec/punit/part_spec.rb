
#
# specifying flor
#
# Sat Oct 27 14:27:00 JST 2018
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'parttest'
    #@unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  #                  +-------------------+--------------------+
  #                  | replies to parent | cancellable        |
  # +-------+--------+-------------------+--------------------+
  # | fork  | part   | immediately       | no (not reachable) |
  # |       | flunk  | never             | no (not reachable) |
  # | flank | flank  | immediately       | yes                |
  # | lose  | norep  | never             | yes                |
  # +-------+--------+-------------------+--------------------+
  #
  # reply/r: false, cancellable/c: false

  describe 'part' do

    it 'replies immediately to its parent' do

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

  describe 'flunk' do

    it 'does not reply to its parent'# do
#
#      r = @unit.launch(
#        %q{
#          concurrence count: 1
#            flunk
#              _skip 4
#              trace 'a'
#            trace 'b'
#          trace 'c'
#        },
#        wait: true)
#
#      expect(r['point']).to eq('terminated')
#      expect(r['payload']['ret']).to eq(nil)
#      expect(r['payload']['parted']).to eq('0_0_0_1')
#
#      expect(
#        @unit.traces.collect(&:text).join(' ')
#      ).to eq(
#        'b c a'
#      )
#    end

    it 'may be cancelled explicitely'
    it 'does not get cancelled when its parent gets cancelled'
  end
end

