
#
# specifying flor
#
# Mon Nov 23 16:25:25 JST 2020
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    sto_uri = RUBY_PLATFORM.match(/java/) ?
      'jdbc:sqlite://tmp/test.db' : 'sqlite://tmp/test.db'

    @unit = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
    @unit.conf['unit'] = 'u_on_receive'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start

    sleep 0.350
  end

  after :each do

    @unit.shutdown
  end

  describe 'on receive' do

    it 'can be used inside of cursor' do

      class OnReceiveSpecTasker < Flor::StagedBasicTasker

        @@counter = 0

        def on_task

          @@counter += 1

          out = @@counter < 3 ? 'continue' : 'break'
          out = nil if attd['n'] == 'omega'
          payload['outcome'] = out

          payload['l'] << "#{nid}/#{attd['n']}/#{out}"

          reply
        end
      end

      @unit.add_tasker('oracle', OnReceiveSpecTasker)

      r = @unit.launch(
        %q{
          cursor
            on receive
              abort _     if f.outcome == 'abort'
              break _     if f.outcome == 'break'
              continue _  if f.outcome == 'continue'
            sequence
              oracle n: 'alpha'
          oracle n: 'omega'
        },
        payload: { l: [] },
        wait: true)

      expect(r).to have_terminated_as_point

      expect(
        r['payload']
      ).to eq(
        'ret' => nil,
        'outcome' => nil,
        'l' => [
          '0_0_1_0/alpha/continue', '0_0_1_0-2/alpha/continue',
          '0_0_1_0-4/alpha/break', '0_1/omega/' ]
      )
    end

    it 'can be used inside of cursor (move instead of start:)' do

      class MobyTasker < Flor::StagedBasicTasker

        @@counter = 0

        def on_task

          @@counter += 1

          payload['outcome'] =
            case attl[1]
            when 'sierra' then @@counter > 3 ? 'break' : 'alpha'
            else nil
            end

          payload['l'] << "#{@@counter}/#{attl[1]}/#{payload['outcome']}"

          reply
        end
      end

      @unit.add_tasker('moby', MobyTasker)

      r = @unit.launch(
        %q{
          cursor
            on receive
              #abort _ if f.outcome == 'abort'
              break _ if f.outcome == 'break'
              move to: 'alpha' if f.outcome == 'alpha'
            move to: 'sierra'
            moby 'alpha'
            moby 'sierra'
          moby 'omega'
        },
        payload: { l: [] },
        wait: true)

      expect(r).to have_terminated_as_point

      expect(
        r['payload']
      ).to eq(
        'ret' => 'omega',
        'outcome' => nil,
        'l' => [
          '1/sierra/alpha', '2/alpha/', '3/sierra/alpha', '4/alpha/',
          '5/sierra/break', '6/omega/' ]
      )
    end
  end
end

