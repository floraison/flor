
#
# specifying flor
#
# Wed Jul 20 05:21:41 JST 2016 outake ryoukan
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('envs/test/etc/conf.json')
    @unit.conf['unit'] = 'u'
    @unit.storage.delete_tables
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.shutdown
  end

  describe 'a tasker' do

    it 'can be "referred" directly' do

      flor = %{
        alpha
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to eq(
        [ '_task', 'alpha', -1 ]
      )
    end

    it 'can be "applied" directly' do

      flor = %{
        alpha _
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('alpha')
      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'].first[0]).to eq('alpha')
      expect(r['payload']['seen'].first[1]).to eq(nil)
      expect(r['payload']['seen'].first[2]).to eq('AlphaTasker')
    end

    it 'passes attributes' do

      flor = %{
        alpha a: 0, b: 1
      }

      r = @unit.launch(flor, wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload'].keys).to eq(%w[ ret seen ])
      expect(r['payload']['seen'].size).to eq(1)
      expect(r['payload']['seen'][0][4]['attd']).to eq({ 'a' => 0, 'b' => 1 })
    end

    it 'preserves "attd" and "attl"' do

      flor = %{
        set f.attd { a: 0, b: -1, c: 2 }
        set f.attl [ 'al', 'bob' ]
        alpha a: 0, b: 1, d: 3
      }

      r = @unit.launch(flor, wait: true)

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
        ).to eq(%w[ alpha ])
    end

    it 'preservers non-keyed atts' do

      flor = %{
        alpha 'bravo' 'charly' 1 count: 2
      }

      r = @unit.launch(flor, wait: true)

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

      flor = %{
        set i 1
        alpha x: 0 if i == 0
        alpha x: 1 if i == 1
        alpha x: 2 unless i == 2
      }

      r = @unit.launch(flor, wait: true)

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

    it 'can be cancelled' do

      flor = %{
        task 'bravo' x: 0
      }

      r = @unit.launch(flor, wait: '0 task')

      expect(r['point']).to eq('task')
      expect(r['nid']).to eq('0')

      sleep 0.420

      r = @unit.queue(
        { 'point' => 'cancel', 'exid' => r['exid'], 'nid' => '0' },
        wait: true)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('bravo cancelled')
    end

    context 'vars' do

      after :all do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            on_task: {
              require: 'charly.rb'
              class: CharlyTasker
            }
          }.ftrim)
        end
      end

      it 'passes no vars by default' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            on_task: {
              require: 'charly.rb'
              class: CharlyTasker
              include_vars: false
            }
          }.ftrim)
        end

        flor = %{
          set a 1
          task 'charly'
        }

        r = @unit.launch(flor, wait: true)

        expect(r['point']).to eq('terminated')

        #pp r['payload']['charly']
        expect(r['payload']['charly']['vars']).to eq(nil)
      end

      it 'passes all vars if include_vars: true' do

        File.open('envs/test/lib/taskers/charly/flor.json', 'wb') do |f|
          f.puts(%{
            on_task: {
              require: 'charly.rb'
              class: CharlyTasker
              include_vars: true
            }
          }.ftrim)
        end

        flor = %{
          set a 1
          set b 2
          sequence vars: { 'b': 3 'c': 4 }
            task 'charly'
        }

        r = @unit.launch(flor, wait: true)

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
            on_task: {
              require: 'charly.rb'
              class: CharlyTasker
              include_vars: [ 'b', 'd' ]
            }
          }.ftrim)
        end

        flor = %{
          set a 1
          set b 2
          sequence vars: { 'b': 3 'c': 4, 'd': 'five' }
            task 'charly'
        }

        r = @unit.launch(flor, wait: true)

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
            on_task: {
              require: 'charly.rb'
              class: CharlyTasker
              include_vars: [ /^flow_/, 'd' ]
            }
          }.ftrim)
        end

        flor = %{
          set flow_name 1
          set flow_x 2
          sequence vars: { 'flow_x': 3 'c': 4, 'd': 'five' }
            task 'charly'
        }

        r = @unit.launch(flor, wait: true)

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
            on_task: {
              require: 'charly.rb'
              class: CharlyTasker
              exclude_vars: [ /^flow_/, 'd' ]
            }
          }.ftrim)
        end

        flor = %{
          set flow_name 1
          set flow_x 2
          sequence vars: { 'flow_x': 3 'c': 4, 'd': 'five' }
            task 'charly'
        }

        r = @unit.launch(flor, wait: true)

        expect(r['point']).to eq('terminated')

        #pp r['payload']['charly']
        expect(
          r['payload']['charly']['vars']
        ).to eq({
          'c' => 4
        })
      end
    end
  end
end

