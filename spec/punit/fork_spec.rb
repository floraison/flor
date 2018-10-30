
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

  describe 'fork' do

    #                         +-------------------+--------------------+
    #                         | replies to parent | cancellable        |
    # +-----------------------+-------------------+--------------------+
    # | fork, forget, fire    | immediately       | no (not reachable) |
    # | lose                  | never             | yes                |
    # | flank (o)             | immediately       | yes                |
    # | xxx                   | never             | no (not reachable) |
    # +-----------------------+-------------------+--------------------+

    it 'forks' do

      r = @unit.launch(
        %q{
          sequence
            set f.forked
              fork
                _skip 4
                trace 'a'
              trace 'b'
          trace 'c'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      #expect(r['payload']['forked']).to eq('0_0_1')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'b c a'
      )
    end
  end
end

