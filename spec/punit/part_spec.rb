
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

    it 'may be cancelled explicitely' do

      r = @unit.launch(
        %q{
          sequence
            trace 'main0'
            set f.parted
              part
                trace 'parted0'
                _skip 2
                trace 'parted1'
                _skip 5
                trace 'parted2'
            trace 'main1'
            _skip 1
            trace 'main2'
            cancel f.parted
          trace 'main3'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('0_0_1_1')
      expect(r['payload']['parted']).to eq('0_0_1_1')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'main0 parted0 main1 parted1 main2 main3'
      )
    end

    it 'does not get cancelled when its parent gets cancelled' do

      r = @unit.launch(
        %q{
          sequence
            trace 'main0'
            part
              trace 'parted0'
              _skip 10
              trace 'parted1'
            trace 'main1'
            cancel '0_0'
            trace 'main2'
          trace 'main3'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('0_0')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'main0 parted0 main1 main3 parted1'
      )
    end
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

    #it 'may be cancelled explicitely'
    #it 'does not get cancelled when its parent gets cancelled'
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

    it 'may be cancelled explicitely' do

      r = @unit.launch(
        %q{
          sequence
            trace 'main0'
            flank
              trace 'flanked0'
              _skip 1
              trace 'flanked1'
            trace 'main1'
            cancel '0_0_1'
            trace 'main2'
          trace 'main3'
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('0_0_1')

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'main0 flanked0 main1 main2 main3'
      )
    end

    it 'gets cancelled when its parent gets cancelled' do

      r = @unit.launch(
        %q{
          concurrence
            sequence tag: 'seqa'
              trace 'seqa0'
              flank
                trace 'flan0'
                _skip 7
                trace 'flan1'
              trace 'seqa1'
              _skip 10
              trace 'seqa2'
            sequence
              trace 'seqb0'
              _skip 10
              trace 'seqb1'
              cancel 'seqa'
              trace 'seqb2'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq('seqa')
        #
        # FIXME at some point "concurrence" merge vs cancelled children
        #       might change...

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(%w[
        seqb0 seqa0 flan0 seqa1 seqb1 seqb2
      ].join(' '))
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

    #it 'may be cancelled explicitely'
    #it 'gets cancelled when its parent gets cancelled'
  end
end

