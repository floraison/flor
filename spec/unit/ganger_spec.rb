
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

  describe 'domain/dot.json and tasker: {}' do

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

  describe 'domain/dot.json and module:' do

    it 'points to multiple taskers' do

      r = @unit.launch(
        %{
          karamel _
          task 'mofon'
        },
        domain: 'kilo',
        wait: 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('mofon')
      expect(r['payload']['seen']).to eq(%w[ karamel mofon ])
    end

    it 'fails if there is no corresponding tasker' do

      r = @unit.launch(
        %q{
          task 'foo'
        },
        domain: 'kilo',
        wait: true)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq('tasker "foo" not found')
    end

    it 'fails if there is no corresponding tasker' do

      r = @unit.launch(
        %q{
          foo _
        },
        domain: 'kilo',
        wait: true)

      expect(r['point']).to eq('failed')
      expect(r['error']['msg']).to eq("don't know how to apply \"foo\"")
    end
  end
end

