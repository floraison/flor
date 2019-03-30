
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

    it 'fails if elements: or elts: is missing' do

      expect {
        @unit.add_iteration(exid: 'xxx', nid: '0_0')
      }.to raise_error(
        ArgumentError, 'missing elements: or element:'
      )
    end

    it 'fails if the execution is not present' do

      expect {
        @unit.add_iteration(exid: 'xxx', nid: '0_0', elts: %w[ a b c ])
      }.to raise_error(
        ArgumentError, 'cannot add iteration to missing execution "xxx"'
      )
    end

    it 'fails if nid: or pnid: is missing' do

      r = @unit.launch(%q{ stall _ }, wait: 'end')

      expect {
        @unit.add_iteration(exid: r['exid'], elements: %w[ a b ])
      }.to raise_error(
        ArgumentError, 'missing nid: or pnid:'
      )
    end

    it 'fails if the target nid: is not present' do

      r = @unit.launch(%q{ stall _ }, wait: 'end')

      expect {
        @unit.add_iteration(
          exid: r['exid'], nid: '0_1', elements: %w[ a b ])
      }.to raise_error(
        ArgumentError,
        'cannot add iteration to missing node "0_1"'
      )
    end

    it 'adds iteration to "c-for-each"' do

      r = @unit.launch(
        %q{
          c-for-each [ 'alpha' 'bravo' ]
            def x
              pile 'x': x
        },
        wait: 'end')

      wait_until { Dir['tmp/pile/task__*.json'].size == 2 }
      sleep 0.350 # give tasker time to write files

      expect(
        Dir['tmp/pile/task__*.json']
          .sort
          .collect { |pa| JSON.parse(File.read(pa))['attd']['x'] }
      ).to eq(%w[
        alpha bravo
      ])

      @unit.add_iteration(
        exid: r['exid'], pnid: '0', elt: 'charly')

      wait_until { Dir['tmp/pile/task__*.json'].size == 3 }
      sleep 0.350 # give tasker time to write files

      expect(
        Dir['tmp/pile/task__*.json']
          .sort
          .collect { |pa| JSON.parse(File.read(pa))['attd']['x'] }
      ).to eq(%w[
        alpha bravo charly
      ])
    end
  end
end

