
#
# specifying flor
#
# Sat Mar 11 13:34:16 JST 2017
#

require 'spec_helper'


describe Flor::Spooler do

  before :all do

    system('mkdir -p envs/test/var/spool')
  end

  after :all do

    system('rm -fR envs/test/var/spool')
  end

  before :each do

    system('rm envs/test/var/spool/*.json > /dev/null 2>&1')
    system('rm envs/test/var/spool/rejected/*.json > /dev/null 2>&1')

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u_spooler'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe '#spool' do

    it 'consumes' do

      exid = Flor.generate_exid('org.acme', 'u0')

      msg = {
        'point' => 'execute',
        'exid' => exid,
        'nid' => '0',
        'tree' => Flor::Lang.parse(%q{ sequence \ set a 1; set b 2 }),
        'payload' => { 'a' => 'A' },
        'vars' => {} }

      File.open('envs/test/var/spool/launch.json', 'wb') do |f|
        f.flock(File::LOCK_EX)
        f.write(JSON.dump(msg))
      end

      r = @unit.wait(exid)

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'a' => 1, 'b' => 2 })
    end

    it 'consumes and puts in spool/consumed/ if present'

    it 'rejects'
    it 'rejects and puts in spool/rejected/ if present'
  end
end

