
#
# specifying flor
#
# Wed Dec 28 15:05:03 JST 2016  Ishinomaki
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'unit with tags' do

    it "doesn't mind a tag name that is a tasker name" do

      r =
        @unit.launch(%{
          sequence tag: alpha
          sequence tag: bravo
        }, wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        @unit.journal
          .select { |m|
            m['point'] == 'left' }
          .collect { |m|
            [ m['nid'], m['point'], m['tags'].join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        0_0:left:alpha
        0_1:left:bravo
      ].join("\n"))
    end
  end
end

