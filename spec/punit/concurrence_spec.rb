
#
# specifying flor
#
# Fri Jun  3 06:09:21 JST 2016
#

require 'spec_helper'


describe 'Flor punit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'pu_concurrence'
    @unit.hooker.add('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'concurrence' do

    it 'has no effect when empty' do

      msg = @unit.launch(
        %q{
          concurrence _
        },
        wait: true)

      expect(msg).to have_terminated_as_point
    end

    it 'has no effect when empty (2)' do

      msg = @unit.launch(
        %q{
          concurrence tag: 'z'
        },
        wait: true)

      expect(msg).to have_terminated_as_point

      wait_until { @unit.journal.find { |m| m['point'] == 'terminated' } }
      wait_until { @unit.journal.find { |m| m['point'] == 'end' } }

      expect(
        @unit.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:z
        receive:0:
        receive::
        left:0:z
        terminated::
        end::
      ].join("\n"))
    end

    it 'executes atts in sequence then children in concurrence' do

      msg = @unit.launch(
        %q{
          concurrence tag: 'x', nada: 'y'
            trace 'a'
            trace 'b'
        },
        wait: true)

      expect(msg).to have_terminated_as_point

      sleep 0.420

      expect(
        @unit.traces.collect(&:text).join(' ')
      ).to eq(
        'a b'
      )

      expect(
        @unit.journal
          .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
      ).to comprise(%w[
        exe:0_2 exe:0_3
        exe:0_2_0 exe:0_3_0
        exe:0_2_0_0 exe:0_3_0_0
      ])
    end

    describe 'by default' do

      it 'merges all the payload, first reply wins' do

        msg = @unit.launch(
          %q{
            concurrence
              sequence
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 0,
          'a' => [ 0, 1 ],
          'h' => { 'a' => 'a', 'b' => 'B' }
        })
      end
    end

    describe 'expect:' do

      it 'accepts an integer > 0' do

        msg = @unit.launch(
          %q{
            concurrence expect: 1
              set f.a 0
              set f.b 1
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']).to eq({ 'ret' => nil, 'a' => 0 })

        wait_until { @unit.journal.find { |m| m['point'] == 'terminated' } }

        expect(
          @unit.journal
            .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
        ).to comprise(%w[
          rec:0 rec:0 can:0_2 rec: ter:
        ])
      end
    end

    context 'remaining:' do

      context "'forget'" do

        it 'prevents child cancelling' do

          msg = @unit.launch(
            %q{
              concurrence expect: 1 rem: 'forget'
                set f.a 0
                set f.b 1
            },
            wait: true)

          expect(msg).to have_terminated_as_point
          expect(msg['payload']).to eq({ 'ret' => nil, 'a' => 0 })

          wait_until { @unit.journal.find { |m| m['point'] == 'terminated' } }

          expect(
            @unit.journal
              .collect { |m| [ m['point'][0, 3], m['nid'] ].join(':') }
          ).to comprise(%w[
            rec:0 rec:0 rec: ter:
          ])
        end
      end

      context "'wait'" do

        # ruote said:
        # There is a third setting, ‘wait’. It behaves like ‘cancel’,
        # but the concurrence waits for the cancelled children to reply.
        # The workitems from cancelled branches are merged in as well.

        it 'waits for the cancelled children' do

          msg = @unit.launch(
            %q{
              concurrence expect: 1 rem: 'wait'
                set f.a 0
                sleep 1
            },
            wait: true)

          expect(msg).to have_terminated_as_point
          expect(msg['payload']).to eq({ 'ret' => nil, 'a' => 0 })

          wait_until { @unit.journal.find { |m| m['point'] == 'terminated' } }

          concurrence_over = @unit.journal.find { |m|
            m['point'] == 'receive' && m['from'] == '0' }
          sleep_over = @unit.journal.find { |m|
            m['point'] == 'receive' && m['nid'] == '0' && m['from'] == '0_3' }

          expect(concurrence_over['m']).to be.>(sleep_over['m'])
        end
      end
    end

    context 'upon cancelling' do

      it 'cancels all its children' do

        msg = @unit.launch(
          %q{
            concurrence
              task 'hole'
              task 'hole'
          },
          wait: '0_1 task')

        r = @unit.queue(
          { 'point' => 'cancel', 'exid' => msg['exid'], 'nid' => '0' },
          wait: true)

        expect(r).to have_terminated_as_point

        wait_until do
          m = @unit.journal.last
          m['point'] == 'end' && m['er'] == 3
        end

        expect(
          @unit.journal
            .drop_while { |m|
              m['point'] != 'task' }
            .collect { |m|
              [ "m#{m['m']}s#{m['sm']}",
                "e#{m['er']}p#{m['pr']}",
                m['point'], m['nid'] ].join('-') }
            .join("\n")
        ).to eq(%w[
              m12s10-e1p1-task-0_0
              m13s11-e1p1-task-0_1
ms-e1p1-end-
            m14s-ep2-cancel-0
              m15s14-e2p2-cancel-0_0
              m16s14-e2p2-cancel-0_1
              m17s15-e2p2-detask-0_0
              m18s16-e2p2-detask-0_1
ms-e2p2-end-
              m19s-ep3-return-0_0
              m20s-ep3-return-0_1
              m21s-e3p3-receive-0_0
              m22s-e3p3-receive-0_1
            m23s21-e3p3-receive-0
            m24s22-e3p3-receive-0
          m25s24-e3p3-receive-
          m26s25-e3p3-terminated-
ms-e3p3-end-
        ].join("\n"))
      end
    end

    describe 'on_receive:/receiver:' do

      it 'is ignored when null' do

        msg = @unit.launch(
          %q{
            set r null
            concurrence on_receive: r
              + 1 2
              + 3 4
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(3)
      end

      it 'hands each child reply to its function' do

        msg = @unit.launch(
          %q{
            define r reply, from, replies, branch_count
              >= (length replies) branch_count
            #concurrence on_receive: r
            concurrence receiver: r
              + 1 2
              + 3 4
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(3)
      end

      it 'can be used with an object ret over/payload' do

        msg = @unit.launch(
          %q{
            define r reply, from, replies, branch_count, over
              set reply.ret (+ reply.ret 10)
              { done: (>= (length replies) branch_count), payload: reply }
            concurrence on_receive: r
              + 1 2
              + 3 4
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(13)
      end

      it "receives an 'over' argument" do

        msg = @unit.launch(
          %q{
            define r reply, from, replies, branch_count, over
              push l over
              true
            set l []
            concurrence on_receive: r
              + 1 2
              + 3 4
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(3)
        expect(msg['vars']['l']).to eq([ false, true ])
      end
    end

    describe 'on_receive' do

      it 'hands each child reply to its function' do

        msg = @unit.launch(
          %q{
            concurrence tag: 'x'
              on_receive (def \ >= (length replies) branch_count)
              + 12 34
              + 56 78
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(46)
      end

      it 'hands each child reply to its function (2)' do

        msg = @unit.launch(
          %q{
            concurrence tag: 'x'
              on_receive (def r f rs bc o \ >= (length rs) bc)
                #(reply, from, replies, branch_count, over)
              + 11 22
              + 33 44
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(33)
      end

      it 'hands each child reply to its block' do

        msg = @unit.launch(
          %q{
            concurrence tag: 'x'
              on_receive
                >= (length replies) branch_count
              + 98 76
              + 54 32
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(174)
      end
    end

    describe 'on_merge:/merger:/merge:' do

      it 'calls its function before the concurrence replies' do

        msg = @unit.launch(
          %q{
            define m rets#, replies, branch_count
              rets | values _ | max _
            #concurrence on_merge: m
            concurrence merger: m
              + 3 4 5
              + 6 7 8
              + 1 2 3
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(21)
      end

      it 'can change the resulting payload' do

        msg = @unit.launch(
          %q{
            define m rets, replies#, branch_count
              set r (rets | values _ | min _)
              { done: true, payload: { ret: r, pls: replies } }
            concurrence on_merge: m
              + 1 2
              + 3 4
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(msg['payload']['ret']).to eq(3)

        expect(
          msg['payload']['pls']
        ).to eq(
          '0_1_1' => { 'ret' => 3 },
          '0_1_2' => { 'ret' => 7 }
        )
      end

      #it 'accepts "first"' # that's the default...

      it 'accepts "first plain"' do

        msg = @unit.launch(
          %q{
            #concurrence merge: { order: 'first', merger: 'plain' }
            concurrence merge: 'fp'
              sequence
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 0,
          'a' => [ 0 ],
          'h' => { 'a' => 'a' }
        })
      end

      it 'accepts "last"/"l"' do

        msg = @unit.launch(
          %q{
            concurrence merge: 'last'
              sequence
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 2,
          'a' => [ 2, 1 ],
          'h' => { 'a' => 'A', 'b' => 'B' }
        })
      end

      it 'accepts "plain"' do

        msg = @unit.launch(
          %q{
            concurrence merge: 'plain'
              sequence
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 0,
          'a' => [ 0 ],
          'h' => { 'a' => 'a' }
        })
      end

      it 'accepts "last plain"' do

        msg = @unit.launch(
          %q{
            concurrence merge: 'last plain'
              sequence
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 2,
          'a' => [ 2 ],
          'h' => { 'a' => 'A' }
        })
      end

      it 'accepts "top"' do

        msg = @unit.launch(
          %q{
            concurrence merge: 'top'
              sequence
                _skip 2 # ensure this branch replies last
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                _skip 1 # ensure this branch replies second
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 0,
          'a' => [ 0, 1 ],
          'h' => { 'a' => 'a', 'b' => 'B' }
        })
      end

      it 'accepts "top plain"' do

        msg = @unit.launch(
          %q{
            concurrence merge: 'tp'
              sequence
                _skip 2 # ensure this branch replies last
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                _skip 1 # ensure this branch replies second
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 0,
          'a' => [ 0 ],
          'h' => { 'a' => 'a' }
        })
      end

      it 'accepts "bottom"' do

        msg = @unit.launch(
          %q{
            concurrence merge: 'bottom'
              sequence
                _skip 2 # ensure this branch replies last
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                _skip 1 # ensure this branch replies second
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 2,
          'a' => [ 2, 1 ],
          'h' => { 'a' => 'A', 'b' => 'B' }
        })
      end

      it 'accepts "bottom plain"' do

        msg = @unit.launch(
          %q{
            concurrence merge: 'bottom plain'
              sequence
                _skip 2 # ensure this branch replies last
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                _skip 1 # ensure this branch replies second
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'ret' => nil,
          'x' => 2,
          'a' => [ 2 ],
          'h' => { 'a' => 'A' }
        })
      end

      it 'accepts "ignore"' do

        msg = @unit.launch(
          %q{
            concurrence on_merge: 'ignore'
              sequence
                _skip 2 # ensure this branch replies last
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                _skip 1 # ensure this branch replies second
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          payload: { 'x' => -1 },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'x' => -1
        })
      end

      it 'accepts "stack"' do

        msg = @unit.launch(
          %q{
            #concurrence on_merge: 'stack' # stores in 'ret' by default
            concurrence on_merge: 'stack:results'
              sequence
                _skip 2 # ensure this branch replies last
                set f.x 0
                set f.h { a: 'a' }
                set f.a [ 0 ]
              sequence
                _skip 1 # ensure this branch replies second
                set f.x 1
                set f.h { b: 'B' }
                set f.a [ 1 1 ]
              sequence
                set f.x 2
                set f.h { a: 'A' }
                set f.a [ 2 ]
          },
          payload: { 'x' => -1 },
          wait: true)

        expect(msg).to have_terminated_as_point

        expect(
          msg['payload']
        ).to eq({
          'x' => -1,
          'results' => [
            { 'ret' => nil,
              'x' => 2, 'h' => { 'a' => 'A' }, 'a' => [ 2 ] },
            { 'ret' => nil,
              'x' => 1, 'h' => { 'b' => 'B' }, 'a' => [ 1, 1 ] },
            { 'ret' => nil,
              'x' => 0, 'h' => { 'a' => 'a' }, 'a' => [ 0 ] } ]
        })
      end
    end

    describe 'on_merge' do

      it 'calls its block' do

        msg = @unit.launch(
          %q{
            concurrence
              on_merge
                rets | values _ | min _
              + 3 4 5
              + 6 7 8
              + 1 2 3
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(6)
      end

      it 'calls its function' do

        msg = @unit.launch(
          %q{
            concurrence
              on_merge (def rs \ rs | values _ | max _)
              + 1 4 5
              + 3 7 8
              + 6 2 3
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(18)
      end

      it 'calls its function (2)' do

        msg = @unit.launch(
          %q{
            concurrence
              on_merge
                def rs
                  rs | values _ | max _
              + 1 4 5
              + 3 7 8
              + 6 2 3
          },
          wait: true)

        expect(msg).to have_terminated_as_point
        expect(msg['payload']['ret']).to eq(18)
      end
    end

    describe 'on_error:' do

      it 'works (single error)' do

        msg = @unit.launch(
          %q{
            set l []
            concurrence on_error: (def msg \ push l "err@$(msg.nid)")
              push l x
              push l 1
          },
          wait: 'terminated')

        expect(msg).to have_terminated_as_point
        expect(msg['vars']['l']).to eq([ 1, 'err@0_1_1_1' ])
      end

      it 'works (green branch replies after error handler replies)' do

        msg = @unit.launch(
          %q{
            set l []
            concurrence on_error: (def msg \ push l "err@$(msg.nid)")
              push l x
              sequence
                sleep 0.4
                push l 1
          },
          wait: 'terminated')

        expect(msg).to have_terminated_as_point
        expect(msg['vars']['l']).to eq([ 'err@0_1_1_1' ])
      end

      it 'works (error in 2 or more branches)' do

        msg = @unit.launch(
          %q{
            set l []
            concurrence on_error: (def msg \ push l "err@$(msg.nid)")
              push l x
              push l y
          },
          wait: 'terminated')

        expect(msg).to have_terminated_as_point
        expect(msg['vars']['l']).to eq([ 'err@0_1_2_1' ])
      end

      context 'when receive error' do

        it 'handles it' do

          msg = @unit.launch(
            %q{
              set l []
              define r reply, from, replies, branch_count
                error "from:$(from)"
                >= (length replies) branch_count
              define e msg err
                push l "err@$(msg.nid)/$(err.msg)"
              concurrence on_receive: r on_error: e
                + 1 2
                + 3 4
            },
            wait: 'terminated')

          expect(msg).to have_terminated_as_point
          expect(msg['vars']['l']).to eq(%w[ err@0_1-1/from:0_3_2 ])
        end
      end

      context 'when merge error' do

        it 'handles it' do

          msg = @unit.launch(
            %q{
              set l []
              define e msg err
                push l "err@$(msg.nid)/$(err.msg)"
              concurrence on_error: e
                on_merge (def rs \ fail "miserably")
                + 1 4 5
                + 3 7 8
                + 6 2 3
            },
            wait: 'terminated')

          expect(msg).to have_terminated_as_point
          expect(msg['vars']['l']).to eq(%w[ err@0_2_1_1-1/miserably ])
        end
      end
    end

    describe 'on_error' do

      it 'works'
    end

    describe 'on error' do

      it 'works'
    end

    describe 'child_on_error:/children_on_error:' do

      it 'sets the on_error: for each child' do

        msg = @unit.launch(
          %q{
            set l []
            concurrence children_on_error: (def msg \ push l "err@$(msg.nid)")
            #concurrence child_on_error: (def msg \ push l "err@$(msg.nid)")
              push l x
              push l y
          },
          wait: 'terminated')

        expect(msg).to have_terminated_as_point
        expect(msg['vars']['l']).to eq([ 'err@0_1_1_1', 'err@0_1_2_1' ])
      end

      it 'is overridden by the child own on_error' do

        msg = @unit.launch(
          %q{
            set l []
            concurrence child_on_error: (def msg \ push l "err@$(msg.nid)")
              push l x
              push l y on_error: (def msg \ push l "y__err@$(msg.nid)")
          },
          wait: 'terminated')

        expect(msg).to have_terminated_as_point
        expect(msg['vars']['l']).to eq([ 'err@0_1_1_1', 'y__err@0_1_2_2' ])
      end
    end

    describe 'child_on_error / children_on_error' do

      it 'sets the on_error: for each child' do

        msg = @unit.launch(
          %q{
            set l []
            concurrence
              #child_on_error
              children_on_error
                push l "err@$(msg.nid)"
              push l x
              push l y
          },
          wait: 'terminated')

        expect(msg).to have_terminated_as_point
        expect(msg['vars']['l']).to eq([ 'err@0_1_1_1', 'err@0_1_2_1' ])
      end
    end
  end
end

