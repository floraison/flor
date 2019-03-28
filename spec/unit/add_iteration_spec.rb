
#
# specifying flor
#
# Thu Mar 28 20:21:20 JST 2019
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'additeration'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start

    system('rm -f tmp/pile/task__*.json')
  end

  after :each do

    @unit.shutdown
  end

  describe '#add_iteration' do

#    it 'fails immediately if overshooting' do
#
#      r = @unit.launch(
#        %q{
#          sequence
#            stall _
#        },
#        wait: 'end')
#
#      expect {
#
#        @unit.add_branch(
#          exid: r['exid'],
#          nid: '0_5',
#          tree: %q{ bob 'do important job' })
#
#      }.to raise_error(
#        ArgumentError,
#        "target 0_5 is off by 4, node 0 has 1 branch"
#      )
#    end

    it 'adds iteration to "c-for-each"' do

      r = @unit.launch(
        %q{
          c-for-each [ 'alpha' 'bravo' ]
            def x
              pile 'x': x
        },
        wait: 'end')

      wait_until { Dir['tmp/pile/task__*.json'].size == 2 }

      expect(
        Dir['tmp/pile/task__*.json']
          .collect { |pa| JSON.parse(File.read(pa))['attd']['x'] }
      ).to eq(%w[
        alpha bravo
      ])

      @unit.add_iteration(
        exid: r['exid'], pnid: '0', elt: 'charly')

      wait_until { Dir['tmp/pile/task__*.json'].size == 3 }

      expect(
        Dir['tmp/pile/task__*.json']
          .collect { |pa| JSON.parse(File.read(pa))['attd']['x'] }
      ).to eq(%w[
        alpha bravo charly
      ])
    end
  end
end

