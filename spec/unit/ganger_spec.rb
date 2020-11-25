
#
# specifying flor
#
# Mon Apr 15 19:13:20 JST 2019
#

require 'spec_helper'


describe Flor::Ganger do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'gangloaspec'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'tasker/dot.json' do

    it 'points to a tasker' do

      r = @unit.launch(
        %{ alpha _ },
        wait: 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('alpha')
    end
  end

  describe 'domain/dot.json' do

    it 'points to multiple taskers' do

      r = @unit.launch(
        %{
          alfa _
          brafo _
        },
        domain: 'juliett',
        wait: 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('brafo')
      expect(r['payload']['seen']).to eq(%w[ alfa brafo ])
    end
  end
end

