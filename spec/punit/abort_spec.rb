
#
# specifying flor
#
# Mon Oct 19 15:49:07 JST 2020
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf[:unit] = 'pu_cancel'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'abort' do

    it 'cancels at the root' do

      r = @unit.launch(
        %q{
          part cancellable: true
            stall _
          part cancellable: false
            stall _
          concurrence
            stall _
            sequence
              abort _
              #cancel '0'
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        @unit.journal
          .select { |m|
            %w[ cancel ].include?(m['point']) }
          .collect { |m|
            %w[ from point nid flavour ].collect { |k|
              m[k] }.compact.map(&:to_s).join(' ') }
      ).to eq([
        # from point to flavour
        '9 cancel 0 cancel',
        '9 cancel 0_1 cancel',
        '0 cancel 0_0',
        '0 cancel 0_2',
        '0_1 cancel 0_1_1',
        '0_0 cancel 0_0_1',
        '0_2 cancel 0_2_0',
        '0_2 cancel 0_2_1',
        '0_2_1 cancel 0_2_1_0'
      ])
    end

    it 'cancels and thus triggers cancel handlers' do

      r = @unit.launch(
        %q{
          trace "before"
          part cancellable: true on_cancel: (def \ trace "ca")
            stall _
          part cancellable: false on_cancel: (def \ trace "cb")
            stall _
          concurrence
            stall _
            sequence
              trace "kabort"
              abort _
          trace "after"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        @unit.journal
          .select { |m|
            %w[ cancel ].include?(m['point']) }
          .collect { |m|
            %w[ from point nid flavour ].collect { |k|
              m[k] }.compact.map(&:to_s).join(' ') }
      ).to eq([
        # from point to flavour
        "9 cancel 0 cancel",
        "9 cancel 0_2 cancel",
        "0 cancel 0_1",
        "0 cancel 0_3",
        "0_2 cancel 0_2_2",
        "0_1 cancel 0_1_2",
        "0_3 cancel 0_3_0",
        "0_3 cancel 0_3_1",
        "0_3_1 cancel 0_3_1_1"
      ])

      expect(
        @unit.traces.collect(&:text)
      ).to eq(%w[
        before kabort cb ca
      ])
    end
  end

  describe 'kabort' do

    it 'kills at the root' do

      r = @unit.launch(
        %q{
          trace "before"
          part cancellable: true on_cancel: (def \ trace "ca")
            stall _
          part cancellable: false on_cancel: (def \ trace "cb")
            stall _
          concurrence
            stall _
            sequence
              trace "kabort"
              kabort _
          trace "after"
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        @unit.traces.collect(&:text)
      ).to eq(%w[
        before kabort
      ])
    end
  end
end

