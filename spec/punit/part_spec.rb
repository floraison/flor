
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
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  #              +-------------------+--------------------+
  #              | replies to parent | cancellable        |
  # +------------+-------------------+--------------------+
  # | part       | immediately       | no (not reachable) |
  # |   r: false | never             | no (not reachable) |
  # | flank      | immediately       | yes                |
  # |   r: false | never             | yes                |
  # +------------+-------------------+--------------------+
  #
  # reply/r: false, cancellable/c: false

  describe 'part' do

    it 'works' do

      r = @unit.launch(
        %q{
          sequence
            part
              trace 'a'
            trace 'b'
          trace 'c'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('0_0_0')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b c'
      )

      expect(
        @unit.journal
          .find { |m| m['point'] == 'ceased' && m['from'] == '0_0_0' }
      ).not_to be_nil

      expect(
        @unit.journal
          .find { |m| m['point'] == 'receive' && m['nid'] == '0_0' }
          .fetch('flavour')
      ).to eq('part')
    end

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

      expect(
        @unit.journal
          .find { |m| m['point'] == 'ceased' && m['from'] == '0_0_0_1' }
      ).not_to be_nil
    end

    it 'may be cancelled explicitely'
    it 'does not get cancelled when its parent gets cancelled'
  end

  describe 'part r: false' do

    it 'does not reply to its parent' do

      r = @unit.launch(
        %q{
          concurrence expect: 1
            part r: false
              _skip 4
              trace 'a'
            trace 'b'
          trace 'c'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'b c a'
      )
    end

    it 'may be cancelled explicitely'
    it 'does not get cancelled when its parent gets cancelled'
  end

  describe 'flank' do

    it 'replies immediately to its parent' do

      r = @unit.launch(
        %q{
          sequence
            flank
              trace 'a'
              #_skip 1
              trace 'b'
            trace 'c'
          trace 'd'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('0_0_0')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a c d'
      )
    end
  end

  describe 'flank r: false' do

    it 'does not reply to its parent' do

      r = @unit.launch(
        %q{
          concurrence expect: 1
            flank r: false
              trace 'a'
              trace 'b'
            sequence
              _skip 1
              trace 'c'
          trace 'd'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a c d'
      )
    end
  end
end

