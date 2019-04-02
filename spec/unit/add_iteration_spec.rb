
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
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
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

    it 'adds iterations to "c-for-each" (array)' do

      r = @unit.launch(
        %q{
          c-for-each [ 'alpha' 'bravo' ]
            def f.x
              stall _
        },
        wait: 'end')

      expect(
        @unit.journal
          .select { |m|
            m['point'] == 'receive' && m['nid'].match(/^0_1_1-\d+$/) }
          .collect { |m|
            m['payload']['x'] }
      ).to eq(%w[
        alpha bravo
      ])

      @unit.add_iteration(
        exid: r['exid'], pnid: '0', elt: 'charly')

      @unit.wait(r['exid'], 'end')

      expect(
        @unit.journal
          .select { |m|
            m['point'] == 'receive' && m['nid'].match(/^0_1_1-\d+$/) }
          .collect { |m|
            m['payload']['x'] }
      ).to eq(%w[
        alpha bravo charly
      ])
    end

    it 'adds iterations to "c-for-each" (object)' do

      r = @unit.launch(
        %q{
          c-for-each { a: 'A', b: 'B' }
            def f.k f.v
              stall _
        },
        wait: 'end')

      expect(
        @unit.journal
          .select { |m|
            m['point'] == 'receive' && m['nid'].match(/^0_1_2-\d+$/) }
          .collect { |m|
            [ m['payload']['k'], m['payload']['v'] ] }
          .flatten
      ).to eq(%w[
        a A b B
      ])

      @unit.add_iteration(
        exid: r['exid'], nid: '0', elts: [ { c: 'C' }, { d: 'D' } ])

      @unit.wait(r['exid'], 'end')

      expect(
        @unit.journal
          .select { |m|
            m['point'] == 'receive' && m['nid'].match(/^0_1_2-\d+$/) }
          .collect { |m|
            [ m['payload']['k'], m['payload']['v'] ] }
          .flatten
      ).to eq(%w[
        a A b B c C d D
      ])
    end

    it 'adds iterations to "for-each" (array)' do

      @unit.launch(
        %q{
          for-each [ 'alpha' ]
            def f.x
              stall _
        },
        wait: 'end')

      r = @unit.journal
        .find { |m| m['point'] == 'receive' && m['nid'] == '0_1_1-1' }

      expect(r['payload']['x']).to eq('alpha')

      @unit.add_iteration(
        exid: r['exid'], nid: '0', elt: 'bravo')

      @unit.wait(r['exid'], 'add')

      @unit.cancel(r['exid'], '0_1_1-1')

      r = @unit.wait(r['exid'], '0_1_1-2 receive')

      expect(r['payload']['x']).to eq('bravo')
    end

    it 'adds iterations to "for-each" (object)' do

      r = @unit.launch(
        %q{
          for-each { a: 'A' }
            def f.k f.v
              stall _
        },
        wait: 'end')

      @unit.add_iteration(
        exid: r['exid'], nid: '0', elts: { b: 'B', c: 'C' })

      @unit.wait(r['exid'], 'add')

      @unit.cancel(r['exid'], '0_1_2-1')

      r = @unit.wait(r['exid'], '0_1_2-2 receive')

      expect(r['payload']['k']).to eq('b')
      expect(r['payload']['v']).to eq('B')

      @unit.cancel(r['exid'], '0_1_2-2')

      r = @unit.wait(r['exid'], '0_1_2-3 receive')

      expect(r['payload']['k']).to eq('c')
      expect(r['payload']['v']).to eq('C')
    end
  end
end

