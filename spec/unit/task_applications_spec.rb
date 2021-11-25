
#
# specifying flor
#
# Wed Jul 20 05:21:41 JST 2016 outake ryoukan
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u_taskapp'
    @unit.hook('journal', Flor::Journal)
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start

    sleep 0.770
  end

  after :each do

    @unit.shutdown
  end

  describe 'a tasker' do

    it 'can be "referred" directly' do

      r = @unit.launch(
        %q{
          alpha
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_tasker', { 'tasker' => 'alpha' }, -1 ]
      )
    end

    it 'can be "applied" directly' do

      r = @unit.launch(
        %q{
          alpha _
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('alpha')
      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'].first[0]).to eq('alpha')
      expect(r['payload']['seen'].first[1]).to eq(nil)
      expect(r['payload']['seen'].first[2]).to eq('AlphaTasker')
    end

    it 'passes attributes' do

      r = @unit.launch(
        %q{
          alpha a: 0, b: 1
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload'].keys).to eq(%w[ ret seen ])
      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'][0][4]['attd']).to eq({ 'a' => 0, 'b' => 1 })
    end

    it 'preserves "attd" and "attl"' do

      r = @unit.launch(
        %q{
          set f.attd { a: 0, b: -1, c: 2 }
          set f.attl [ 'al', 'bob' ]
          alpha a: 0, b: 1, d: 3
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload'].keys).to eq(%w[ ret attd attl seen ])

      expect(r['payload']['attd']
        ).to eq({ 'a' => 0, 'b' => -1, 'c' => 2 })
      expect(r['payload']['attl']
        ).to eq(%w[ al bob ])
      expect(r['payload']['seen'].size
        ).to eq(1)
      expect(r['payload']['seen'].first[4]['attd']
        ).to eq({ 'a' => 0, 'b' => 1, 'd' => 3 })
      expect(r['payload']['seen'].first[4]['attl']
        ).to eq([ 'alpha' ])
    end

    it 'preserves non-keyed atts' do

      r = @unit.launch(
        %q{
          alpha 'bravo' 'charly' 1 count: 2
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload'].keys).to eq(%w[ ret seen ])

      expect(
        r['payload']['seen'].last.last['attl']
      ).to eq([
        'alpha', 'bravo', 'charly', 1
      ])
      expect(
        r['payload']['seen'].last.last['attd']
      ).to eq({
        'count' => 2
      })
    end

    it 'respects postfix conditionals' do

      r = @unit.launch(
        %q{
          set i 1
          alpha x: 0 if i == 0
          alpha x: 1 if i == 1
          alpha x: 2 unless i == 2
        },
        wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['seen'].collect(&:last)
      ).to eq([
        { 'payload' => { 'ret' => nil },
          'attl' => %w[ alpha ], 'attd' => { 'x' => 1 } },
        { 'payload' => { 'ret' => nil },
          'attl' => %w[ alpha ], 'attd' => { 'x' => 2 } }
      ])
    end

    it 'is kept track of' do

      r = @unit.launch(
        %q{
          concurrence
            task 'bravo' 'investigate venue'
            bravo 'investigate transportation'
        },
        #wait: '0_1 task')
        wait: 'end') # wait until end of session

      wait_until { @unit.executions.count > 0 }

      e = @unit.executions.first(exid: r['exid'])
      ps = @unit.pointers.where(exid: r['exid']).all

      expect(e.send(:_data)['tasks']).to eq(nil)
        # legacy check

      expect(
        ps.collect { |p| [ p[:nid], p[:type], p[:name], p[:value] ] }
      ).to eq([
        [ '0_0', 'tasker', 'bravo', 'investigate venue' ],
        [ '0_1', 'tasker', 'bravo', 'investigate transportation' ]
      ])
    end

    it 'can be cancelled' do

      r = @unit.launch(
        %q{
          task 'bravo' x: 0
        },
        wait: '0 task')

      expect(r['point']).to eq('task')
      expect(r['nid']).to eq('0')

      wait_until { @unit.executions.count > 0 }

      r = @unit.queue(
        { 'point' => 'cancel', 'exid' => r['exid'], 'nid' => '0' },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('bravo cancelled')
    end

    it 'can postpone a task'

    context 'vars' do

      after :all do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
          }.ftrim)
        end
      end

      it 'passes no vars by default' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
            include_vars: false
          }.ftrim)
        end

        r = @unit.launch(
          %q{
            set a 1
            task 'charly'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        #pp r['payload']['charly']
        expect(r['payload']['charly']['vars']).to eq(nil)
      end

      it 'passes all vars if include_vars: true' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
            include_vars: true
          }.ftrim)
        end

        r = @unit.launch(
          %q{
            set a 1
            set b 2
            sequence vars: { 'b': 3 'c': 4 }
              task 'charly'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        #pp r['payload']['charly']
        expect(
          r['payload']['charly']['vars']
        ).to eq({
          'a' => 1, 'b' => 3, 'c' => 4
        })
      end

      it 'passes some vars if include_vars: [ a, b ]' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
            include_vars: [ 'b', 'd' ]
          }.ftrim)
        end

        r = @unit.launch(
          %q{
            set a 1
            set b 2
            sequence vars: { 'b': 3 'c': 4, 'd': 'five' }
              task 'charly'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        #pp r['payload']['charly']
        expect(
          r['payload']['charly']['vars']
        ).to eq({
          'b' => 3, 'd' => 'five'
        })
      end

      it 'passes some vars if include_vars: [ /reg/, /ex/ ]' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
            include_vars: [ /^flow_/, 'd' ]
          }.ftrim)
        end

        r = @unit.launch(
          %q{
            set flow_name 1
            set flow_x 2
            sequence vars: { 'flow_x': 3 'c': 4, 'd': 'five' }
              task 'charly'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        #pp r['payload']['charly']
        expect(
          r['payload']['charly']['vars']
        ).to eq({
          'flow_name' => 1, 'flow_x' => 3, 'd' => 'five'
        })
      end

      it 'rejects some vars if exclude_vars: [ /reg/, /ex/ ]' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
            exclude_vars: [ /^flow_/, 'd' ]
          }.ftrim)
        end

        r = @unit.launch(
          %q{
            set flow_name 1
            set flow_x 2
            sequence vars: { 'flow_x': 3 'c': 4, 'd': 'five' }
              task 'charly'
          },
          wait: true)

        expect(r['point']).to eq('terminated')

        #pp r['payload']['charly']
        expect(
          r['payload']['charly']['vars']
        ).to eq({
          'c' => 4
        })
      end

      it 'passes domain vars' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
            include_vars: true
          }.ftrim)
        end

        r = @unit.launch(
          %q{
            set flow_name 'test_dvariables'
            set flow_x 0
            sequence vars: { 'flow_x': 1 'flow_y': 2 }
              task 'charly'
          },
          vdomain: 'com.acme',
          wait: true)

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['charly']['vars']
            .reject { |k, v| k[0, 1] == '_' }
        ).to eq({
          'flow_name' => 'test_dvariables',
          'flow_x' => 1, 'flow_y' => 2,
          'company' => 'ACME',
          'root' => 'envs/test/etc/variables/com.acme'
        })
      end

      it 'passes vars through \'fparent\'' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            require: 'charly.rb'
            class: CharlyTasker
            include_vars: true
          }.ftrim)
        end

        r = @unit.launch(
          %q{
            on 'zap'
              task 'charly'
            set x 0
            set y 1
            signal 'zap'
            stall _
          },
          wait: 'task')

        expect(r['point']).to eq('task')
        expect(r['vars']['x']).to eq(0)
        expect(r['vars']['y']).to eq(1)
      end
    end
  end

  describe 'a ruby tasker' do

    it 'accepts taskers that initialize with tasker, conf, message' do

      r = @unit.launch(
        %q{
          set f.a 1
          emil _
        },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['emil']).to eq('was here')
    end
  end

  context 'with a domain tasker' do

    it 'reroutes to specific taskers (via "task")' do

      r = @unit.launch(
        %q{ task 'acme_alpha' },
        domain: 'net.acme', wait: true)

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq('acme_alpha')
      expect(r['payload']['seen'].size).to eq(1)

      expect(
        r['payload']['seen'][0][0, 3]
      ).to eq([
        'alpha', nil, 'AlphaTasker'
      ])
      expect(
        r['payload']['seen'][0][4]
      ).to eq({
        'payload' => { 'ret' => 'acme_alpha' },
        'attl' => %w[ acme_alpha ],
        'attd' => {}
      })
    end

    it 'reroutes to specific taskers' do

      r = @unit.launch(
        %q{ acme_alpha _ },
        domain: 'net.acme', wait: true)

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq('acme_alpha')
      expect(r['payload']['seen'].size).to eq(1)
    end

    it "fails explicitely if the domain tasker doesn't know where to reroute" do

      r = @unit.launch(
        %q{ unknown_alpha _ },
        domain: 'net.acme', wait: true)

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq("don't know how to apply \"unknown_alpha\"")
    end

    it "fails explicitely if the domain tasker doesn't know where to reroute" do

      r = @unit.launch(
        %q{
          task 'unknown_alpha'
        },
        domain: 'net.acme', wait: true)

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['msg']
        ).to eq('tasker "unknown_alpha" not found')
    end
  end

  context 'tasker error replies vs on_error' do

    it 'works' do

      r = @unit.launch(
        %q{
          cursor
            on error \ break 'broken'
            task 'failfox2'
            'not broken'
        },
        wait: 'terminated')

      expect(r['point']).to eq('terminated')
      expect(r['pr']).to eq(3)
      expect(r['payload']['ret']).to eq('broken')

      wait_until { @unit.journal.find { |m| m['point'] == 'terminated' } }

      expect(
        @unit.journal
          .each_with_index
          .collect { |m, i| "#{i}:#{m['point']}:#{m['from']}->#{m['nid']}" }
          .slice(0, 33) # trim out the last 'end'
          .join("\n")
      ).to eq(%{
        0:execute:->0
        1:execute:0->0_0
        2:execute:0->0_0
        3:execute:0_0->0_0_0
        4:receive:0_0_0->0_0
        5:receive:0_0->0
        6:execute:0->0_1
        7:execute:0_1->0_1_0
        8:execute:0_1_0->0_1_0_0
        9:receive:0_1_0_0->0_1_0
        10:receive:0_1_0->0_1
        11:task:0_1->0_1
        12:end:->
        13:failed:0_1->0_1
        14:cancel:0->0_1
        15:detask:0_1->0_1
        16:end:->
        17:return:->0_1
        18:receive:->0_1
        19:receive:0_1->0
        20:execute:0->0_0_0-1
        21:execute:0_0_0-1->0_0_0_2-1
        22:execute:0_0_0_2-1->0_0_0_2_0-1
        23:execute:0_0_0_2_0-1->0_0_0_2_0_0-1
        24:receive:0_0_0_2_0_0-1->0_0_0_2_0-1
        25:receive:0_0_0_2_0-1->0_0_0_2-1
        26:cancel:0_0_0_2-1->0
        27:cancel:0->0_0_0-1
        28:cancel:0_0_0-1->0_0_0_2-1
        29:receive:0_0_0_2-1->0_0_0-1
        30:receive:0_0_0-1->0
        31:receive:0->
        32:terminated:0->
      }.ftrim)
    end
  end
end

