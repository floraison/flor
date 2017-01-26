
#
# specifying flor
#
# Sun Aug 21 14:10:19 JST 2016
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

  describe 'domain variables' do

    it 'lookups' do

      r =
        @unit.launch(%{
          company
        }, domain: 'com.acme', wait: true)

      expect(r['point']).to eq('terminated')
      expect(Flor.domain(r['exid'])).to eq('com.acme')
      expect(r['payload']).to eq({ 'ret' => 'ACME' })
    end

    it 'are prefixed optionally with dv.' do

      r =
        @unit.launch(%{
          [ company, dv.company ]
        }, domain: 'com.acme', vars: { 'company' => 'EMCA' }, wait: true)

      expect(r['point']).to eq('terminated')
      expect(Flor.domain(r['exid'])).to eq('com.acme')
      expect(r['payload']['ret']).to eq(%w[ EMCA ACME ])
    end

    context 'vdomain: false' do

      it 'prevents domain variables lookup' do

        r =
          @unit.launch(%{
            company
          }, vdomain: false, domain: 'com.acme', wait: true)

        expect(r['point']).to eq('failed')
        expect(r['error']['msg']).to eq("don't know how to apply \"company\"")
      end
    end

    context 'vdomain: "org.dom"' do

      it 'reconnects the domain variables lookup to another domain' do

        r =
          @unit.launch(%{
            company
          }, domain: 'org.acme', vdomain: 'com.acme', wait: true)

        expect(r['point']).to eq('terminated')
        expect(Flor.domain(r['exid'])).to eq('org.acme')
        expect(r['payload']).to eq({ 'ret' => 'ACME' })
      end
    end
  end
end

