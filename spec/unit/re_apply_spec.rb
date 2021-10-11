
#
# specifying flor
#
# Mon Feb 20 17:54:35 JST 2017
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'reapply'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 're-applying a node' do

    it 'works (node with children)' do

      r = @unit.launch(
        %q{
          sequence
            sequence
              stall _
        },
        wait: '0_0_0 receive; end')

      exid = r['exid']

      new_tree =
        %q{
          sequence
            alpha _
        }

      @unit.re_apply(
        exid: exid, nid: '0_0',
        tree: new_tree,
        payload: { 'text' => 'hello world' })

      r = @unit.wait(exid, 'terminated')

      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'][0][0]).to eq('alpha')
      expect(r['payload']['text']).to eq('hello world')
    end

    it 'works (leaf node)' do

      r = @unit.launch(
        %q{
          sequence
            stall _
        },
        wait: '0_0 receive; end')

      exid = r['exid']

      new_tree = %q{ alpha _ }

      @unit.re_apply(
        exid: exid, nid: '0_0',
        tree: new_tree,
        payload: { 'text' => 'hello world' })

      r = @unit.wait(exid, 'terminated')

      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'][0][0]).to eq('alpha')
      expect(r['payload']['text']).to eq('hello world')
    end

    it 'works (tasker leaf node)' do

      r = @unit.launch(
        %q{
          sequence
            hole _
        },
        wait: '0_0 task; end')

      exid = r['exid']

      new_tree = %{ alpha _ }

      @unit.re_apply(
        exid: exid, nid: '0_0',
        tree: new_tree,
        payload: { 'text' => 'hello world' })

      r = @unit.wait(exid, 'terminated')

      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'][0][0]).to eq('alpha')
      expect(r['payload']['text']).to eq('hello world')
    end

    it 'works (subnid node)' do

      r = @unit.launch(
        %q{
          set a 0
          loop
            set a (+ a 1)
            continue _ if a < 2
            stall _
        },
        wait: 'end')

      exid = r['exid']

      new_tree = %q{ alpha _ }

      @unit.re_apply(
        exid: exid, nid: '0_1_2-1',
        tree: new_tree,
        payload: { 'text' => 'hello world -1' })

      r = @unit.wait(exid, '0_1_2-2 receive')

      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'][0][0]).to eq('alpha')
      expect(r['payload']['text']).to eq('hello world -1')
    end
  end

  describe 're-applying a node vs full_tree' do

    it 'works (node with children)' do

      r = @unit.launch(
        %q{
          sequence
            sequence tag: 'alpha'
              stall _
        },
        wait: '0_0_0 receive; end')

      exid = r['exid']
      exe = wait_until { @unit.executions[exid: exid] }
#puts Flor.tree_to_s(exe.full_tree)

      expect(exe.full_tree).to eq(
        ["sequence", [
          ["sequence", [
            ["_att", [["tag", [], 3], ["_sqs", "alpha", 3]], 3],
            ["stall", [["_att", [["_", [], 4]], 4]], 4]], 3]], 2])

      new_tree =
        %q{
          sequence tag: 'bravo'
            stall _
        }

      @unit.re_apply(
        exid: exid, nid: '0_0',
        tree: new_tree,
        payload: { 'text' => 'hello again' })

      r = @unit.wait(exid, '0_0_1 receive; end')
      exe = @unit.executions[exid: exid]

      expect(exe.full_tree.tree_trim).to eq(
        ["sequence", [
          ["sequence", [
            ["_att", [["tag", [], 2], ["_sqs", "bravo", 2]], 2],
            ["stall", [["_att", [["_", [], 3]], 3]], 3]], 2, "spec/unit/re_apply_spec.rb:167"]], 2]
      )
    end

#    it 'works (leaf node)' do
#
#      r = @unit.launch(
#        %q{
#          sequence
#            stall _
#        },
#        wait: '0_0 receive; end')
#
#      exid = r['exid']
#
#      new_tree = %q{ alpha _ }
#
#      @unit.re_apply(
#        exid: exid, nid: '0_0',
#        tree: new_tree,
#        payload: { 'text' => 'hello world' })
#
#      r = @unit.wait(exid, 'terminated')
#
#      expect(r['payload']['seen'].size).to eq(1)
#      expect(r['payload']['seen'][0][0]).to eq('alpha')
#      expect(r['payload']['text']).to eq('hello world')
#    end
#
#    it 'works (tasker leaf node)' do
#
#      r = @unit.launch(
#        %q{
#          sequence
#            hole _
#        },
#        wait: '0_0 task; end')
#
#      exid = r['exid']
#
#      new_tree = %{ alpha _ }
#
#      @unit.re_apply(
#        exid: exid, nid: '0_0',
#        tree: new_tree,
#        payload: { 'text' => 'hello world' })
#
#      r = @unit.wait(exid, 'terminated')
#
#      expect(r['payload']['seen'].size).to eq(1)
#      expect(r['payload']['seen'][0][0]).to eq('alpha')
#      expect(r['payload']['text']).to eq('hello world')
#    end
#
#    it 'works (subnid node)' do
#
#      r = @unit.launch(
#        %q{
#          set a 0
#          loop
#            set a (+ a 1)
#            continue _ if a < 2
#            stall _
#        },
#        wait: 'end')
#
#      exid = r['exid']
#
#      new_tree = %q{ alpha _ }
#
#      @unit.re_apply(
#        exid: exid, nid: '0_1_2-1',
#        tree: new_tree,
#        payload: { 'text' => 'hello world -1' })
#
#      r = @unit.wait(exid, '0_1_2-2 receive')
#
#      expect(r['payload']['seen'].size).to eq(1)
#      expect(r['payload']['seen'][0][0]).to eq('alpha')
#      expect(r['payload']['text']).to eq('hello world -1')
#    end
  end
end

