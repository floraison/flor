
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
        "9 cancel 0 cancel",
        "9 cancel 0_1 cancel",
        "0 cancel 0_0",
        "0 cancel 0_2",
        "0_1 cancel 0_1_1",
        "0_0 cancel 0_0_1",
        "0_2 cancel 0_2_0",
        "0_2 cancel 0_2_1",
        "0_2_1 cancel 0_2_1_0",
        "0 cancel 0_0"
      ])
    end

  end

  describe 'kabort' do

    it 'kills at the root'
  end
end

