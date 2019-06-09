
#
# specifying flor
#
# Tue Oct  9 21:06:06 JST 2018
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    #@unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'Flor::Execution model' do

    describe '#to_h' do

      it 'details the execution' do

        exid =
          @unit.launch(
            %{
              concurrence
                stall _
                fail 'nada'
                bravo 'do the job'
                nemo
            })

        execution = wait_until {
          @unit.executions.first(exid: exid) }

        expect(execution.unit).to eq(@unit)
        expect(execution.storage.class).to eq(Flor::Storage)

        expect(execution.closing_messages.size).to eq(1)
        expect(execution.closing_messages[0]['point']).to eq('task')

        h = execution.to_h
        d = h[:data]
        m = h[:meta]

        expect(h[:size]).to be_between(805, 945)

        expect(m[:counts][:nodes]).to eq(5)
        expect(m[:counts][:tasks]).to eq(1)
        expect(m[:counts][:failures]).to eq(2)
        expect(m[:nids][:tasks]).to eq(%w[ 0_2 ])
        expect(m[:nids][:failures]).to eq(%w[ 0 0_3 ])
      end
    end

    describe '#lookup_nodes' do

      describe "(/^0_0_1-/)" do

        it 'returns the matching nodes' do

          exid =
            @unit.launch(
              %{
                c-each [ 0 1 2 3 ]
                  stall _
              })

          execution = wait_until {
            @unit.executions.first(exid: exid) }

          ns = execution.lookup_nodes(/^0_1_0-/)

          expect(ns.class
            ).to eq(Array)
          expect(ns.size
            ).to eq(4)
          expect(ns.first.class
            ).to eq(Hash)
          expect(ns.collect { |n| n['nid'] }
            ).to eq(%w[ 0_1_0-1 0_1_0-2 0_1_0-3 0_1_0-4 ])
        end
      end

      describe "('c-each f.customers')" do

        it 'returns the matching nodes' do

          exid =
            @unit.launch(
              %{
                concurrence
                  c-each f.customers
                    #bob "meet customer" customer: elt
                    stall _
                  c-each [ 0 1 ]
                    stall _
              },
              payload: { 'customers' => %w[ aa bb ] })

          execution = wait_until {
            @unit.executions.first(exid: exid) }

          ns = execution.lookup_nodes('c-each f.customers')

          expect(ns.class).to eq(Array)
          expect(ns.collect { |n| n['nid'] }).to eq(%w[ 0_0 ])

          ns = execution.lookup_nodes(/c-each/)

          expect(ns.collect { |n| n['nid'] }).to eq(%w[ 0_0 0_1 ])
        end
      end

      describe "('tagname')" do

        it 'returns the matching nodes' do

          exid =
            @unit.launch(
              %{
                concurrence
                  stall tag: 'alpha'
                  stall tag: 'alpha'
                  stall tag: 'bravo'
              })

          execution = wait_until {
            @unit.executions.first(exid: exid) }

          ns = execution.lookup_nodes('alpha')

          expect(ns.collect { |n| n['nid'] }).to eq(%w[ 0_0 0_1 ])
        end
      end

      describe "(/tagname/)" do

        it 'returns the matching nodes' do

          exid =
            @unit.launch(
              %{
                concurrence
                  stall tag: 'alice'
                  stall tag: 'alfred'
                  stall tag: 'bob'
              })

          execution = wait_until {
            @unit.executions.first(exid: exid) }

          ns = execution.lookup_nodes(/^al/)

          expect(ns.collect { |n| n['nid'] }
            ).to eq(%w[ 0_0 0_1 ])
          expect(ns.collect { |n| n['tags'] }.flatten
            ).to eq(%w[ alice alfred ])
        end
      end
    end

    describe '#lookup_node' do

      describe "(/^0_0_1-/)" do

        it 'returns the first matching node' do

          exid =
            @unit.launch(%{
              c-each [ 0 1 ]
                stall _
            })

          execution = wait_until {
            @unit.executions.first(exid: exid) }

          n = execution.lookup_node(/^0_1_0-/)

          expect(n.class).to eq(Hash)
          expect(n['nid']).to eq('0_1_0-1')
        end
      end

      describe "('c-each f.customers')" do

        it 'returns the first matching node' do

          exid =
            @unit.launch(
              %{
                concurrence
                  c-each f.customers
                    #bob "meet customer" customer: elt
                    stall _
                  c-each [ 0 1 ]
                    stall _
              },
              payload: { 'customers' => %w[ aa bb ] })

          execution = wait_until {
            @unit.executions.first(exid: exid) }

          n = execution.lookup_node('c-each f.customers')

          expect(n['nid']).to eq('0_0')

          n = execution.lookup_node(/c-each/)

          expect(n['nid']).to eq('0_0')
        end
      end

      describe "('0_0_1-1')" do

        it 'returns the first matching node' do

          exid =
            @unit.launch(%{
              c-each [ 0 1 ]
                stall _
            })

          execution = wait_until {
            @unit.executions.first(exid: exid) }

          n = execution.lookup_node('0_1_0-1')

          expect(n.class).to eq(Hash)
          expect(n['nid']).to eq('0_1_0-1')
        end
      end
    end

    describe '#lookup_nids' do

      it 'returns the nids of the matching nodes' do

        exid =
          @unit.launch(
            %{
              concurrence
                stall tag: 'alice'
                stall tag: 'alfred'
                stall tag: 'bob'
            })

        execution = wait_until {
          @unit.executions.first(exid: exid) }

        nids = execution.lookup_nids(/^al/)

        expect(nids).to eq(%w[ 0_0 0_1 ])
      end
    end

    describe '#lookup_nid' do

      it 'returns the nid of the first matching node' do

        exid =
          @unit.launch(
            %{
              concurrence
                stall tag: 'alice'
                stall tag: 'alfred'
                stall tag: 'bob'
            })

        execution = wait_until {
          @unit.executions.first(exid: exid) }

        nid = execution.lookup_nid(/^al/)

        expect(nid).to eq('0_0')
      end
    end
  end
end

