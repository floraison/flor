
#
# specifying flor
#
# Thu Feb 14 12:56:01 JST 2019  Basset Cafe
#

require 'spec_helper'


describe Flor::HashLoader do

  before :each do

    unit = OpenStruct.new(conf: {})

    @loader = Flor::HashLoader.new(unit)
  end

  describe '#variables' do

    before :each do

      environment = {
        variables: {
          'net' => { 'car' => 'fiat' },
          'net.example' => {
            'alpha' => {
              'car' => 'lancia', 'flower' => 'forget-me-not' },
            'car' => 'alfa romeo', 'flower' => 'rose' },
          'org.example' => { 'car' => nil, 'flower' => 'lilly' },
        }
      }

      unit = OpenStruct.new(conf: { 'lod_environment' => environment })

      @loader = Flor::HashLoader.new(unit)
    end

    {
      'net' =>
        { 'car' => 'fiat' },
      'net.example' =>
        { 'car' => 'alfa romeo', 'flower' => 'rose' },
      'org.example' =>
        { 'car' => nil, 'flower' => 'lilly' },
      'net.example.alpha' =>
        { 'car' => 'lancia', 'flower' => 'forget-me-not' }

    }.each do |d, h|

      it "loads variable \"#{d}\"" do

        r = @loader.variables(d)
        h.each { |k, v| expect(r[k]).to eq(v) }
      end
    end
  end

  describe '#library' do

    before :each do

      @loader.add(:library, 'net.example.flow1', "task 'nathalie'")
      @loader.add(:library, 'org.example.flow1', "task 'oskar'")
    end

    {
      [ 'net.example', 'flow1' ] =>
        [ 'net.example.flow1', "task 'nathalie'" ],
      [ 'org.example.flow1' ] =>
        [ 'org.example.flow1', "task 'oskar'" ],
      [ 'org.example.flow99' ] =>
        nil

    }.each do |ks, (path, code)|

      it "loads lib at #{ks.inspect}" do

        pa, co = @loader.library(*ks)
        co = co.strip if co

        expect(pa).to eq(path)
        expect(co).to eq(code)
      end
    end
  end

  describe '#tasker' do

    before :each do

      @loader.add(
        :tasker, 'alice',
        { description: 'basic alice', a: 'a' })
      @loader.add(
        :tasker, 'org.example.alice',
        { description: 'org.example alice', ao: 'AO' })
      @loader.add(
        :tasker, 'net.example.bob',
        { description: 'net.example bob', bn: 'BN' })
      @loader.add(
        :tasker, 'org.example.bob',
        { description: 'org.example bob', bo: 'BO' })

      @loader.add(
        :tasker, 'com.example.tasker',
        { description: '/cet/dot.json' })
      @loader.add(
        :tasker, 'com.example.alpha.tasker',
        { description: '/usr/ceat/dot.json' })
      @loader.add(
        :tasker, 'com.example.bravo.tasker',
        { description: '/usr/cebt/flor.json' })
      @loader.add(
        :tasker, 'com.example.charly.tasker',
        { description: '/cect.json' })

      @loader.add(
        :tasker, 'org.example.charly',
        { description: 'org.example charly' })

      @loader.add(
        :tasker, 'mil.example.staff',
        { description: 'mil.example.staff' })
      @loader.add(
        :tasker, 'mil.example.ground.staff',
        { description: 'mil.example.ground.staff' })
      @loader.add(
        :tasker, 'mil.example.air.command',
        { description: 'mil.example.air.command' })
      @loader.add(
        :tasker, 'mil.example.air.tactical.command',
        { description: 'mil.example.air.command' })

      @loader.add(
        :tasker, 'mil.example.air.tactical.intel',
        [ { point: 'task', description: 'task d' },
          { point: 'detask', description: 'detask d' } ])

      @loader.add(
        :tasker, 'edu.example.echo',
        %{
          description: 'edu.example echo'
          class: "Edu::Example::Taskers::$(f.flavour|capitalize _)"
        })
    end

    {
      [ '', 'alice' ] =>
        [ 'basic alice', %w[ description a _path root ] ],

      [ 'net.example', 'alice' ] =>
        [ 'basic alice', %w[ description a _path root ] ],

      [ 'org.example', 'alice' ] =>
        [ 'org.example alice', %w[ description ao _path root ] ],

      [ '', 'bob' ] => [
        nil ],

      [ 'net.example', 'bob' ] =>
        [ 'net.example bob', %w[ description bn _path root ] ],

      [ 'org.example', 'bob' ] =>
        [ 'org.example bob', %w[ description bo _path root ] ],

      [ 'org.example.bob', nil ] =>
        [ 'org.example bob', %w[ description bo _path root ] ],

    }.each do |ks, (desc, keys)|

      it "loads tasker conf at #{ks.inspect}" do

        t = @loader.tasker(*ks)

        if desc
          expect(t['description']).to eq(desc)
          expect(t.keys).to eq(keys)
        else
          expect(t).to eq(nil)
        end
      end
    end

    {
      [ 'com.example.tasker', nil ] => '/cet/dot.json',
      [ 'com.example', 'tasker' ] => '/cet/dot.json',
      [ 'com.example.alpha.tasker', nil ] => '/usr/ceat/dot.json',
      [ 'com.example.alpha', 'tasker' ] => '/usr/ceat/dot.json',
      [ 'com.example.bravo.tasker', nil ] => '/usr/cebt/flor.json',
      [ 'com.example.bravo', 'tasker' ] => '/usr/cebt/flor.json',
      [ 'com.example.charly', 'tasker' ] => '/cect.json',

    }.each do |ks, desc|

      it "loads the domain tasker conf at #{ks.inspect}" do

        tc = @loader.tasker(*ks)

        expect(tc['description']).to eq(desc)
      end
    end

    {
      [ 'mil.example', 'staff' ] => [
        'mil.example.staff',
        nil ],
      [ 'mil.example.ground', 'staff' ] => [
        'mil.example.ground.staff',
        nil ],
      [ 'mil.example.air', 'command' ] => [
        'mil.example.air.command',
        nil ],
      [ 'mil.example.air.tactical', 'command' ] => [
        'mil.example.air.command',
        'mil.example.air.tactical' ],

    }.each do |ks, (desc, path)|

      it "loads the do.main.json tasker conf at #{ks.inspect}" do

        tc = @loader.tasker(*ks)

        expect(tc['description']).to eq(desc)
        expect(tc['_path']).to eq(path) if path
      end
    end

    it 'loads a tasker array configuration do.ma.in.json' do

      tc = @loader.tasker('mil.example.air.tactical', 'intel')

      expect(tc.size).to eq(2)

      expect(tc[0]['point']).to eq('task')
      expect(tc[1]['point']).to eq('detask')
      expect(tc[0]['_path']).to eq('mil.example.air.tactical')
      expect(tc[1]['_path']).to eq('mil.example.air.tactical')
    end

    it 'uses the message when loading the tasker configuration' do

      tc = @loader.tasker(
        'edu.example', 'echo',
        { 'payload' => { 'flavour' => 'vanilla' } })

      expect(tc['description']).to eq('edu.example echo')
      expect(tc['class']).to eq('Edu::Example::Taskers::Vanilla')
      expect(tc['_path']).to eq('edu.example')
      expect(tc['root']).to eq(nil)
    end
  end

  describe '#hooks' do

    before :each do

      @loader.add(
        :hook, '',
        [ { point: 'execute',
            require: 'xyz/my_hooks.rb', class: 'Xyz::MyExecuteHook' },
          %{
            point: terminated,
            require: 'xyz/my_hooks.rb'
            class: 'Xyz::MyGenericHook'
          } ])
      @loader.add(
        :hook, 'org.example',
        [ { point: 'execute',
            require: 'xyz/oe_hooks.rb', class: 'Xyz::OeExecuteHook' } ])
    end

    it 'returns the sum of the hooks for a domain' do

      hooks = @loader.hooks('org.example')

      expect(hooks.size).to eq(3)

      expect(hooks[0]['point']).to eq('execute')
      expect(hooks[0]['require']).to eq('xyz/my_hooks.rb')
      expect(hooks[0]['class']).to eq('Xyz::MyExecuteHook')
      expect(hooks[0]['_path']).to eq('org.example')

      expect(hooks[1]['point']).to eq('terminated')
      expect(hooks[1]['require']).to eq('xyz/my_hooks.rb')
      expect(hooks[1]['class']).to eq('Xyz::MyGenericHook')
      expect(hooks[1]['_path']).to eq('org.example')

      expect(hooks[2]['point']).to eq('execute')
      expect(hooks[2]['require']).to eq('xyz/oe_hooks.rb')
      expect(hooks[2]['class']).to eq('Xyz::OeExecuteHook')
      expect(hooks[2]['_path']).to eq('org.example')
    end
  end

  describe '#domains' do

    before :each do

      @loader.add(:hook, '', [ { point: 'execute' } ])
      @loader.add(:hook, 'org.example', [ { point: 'execute' } ])
      @loader.add(:hook, 'org.example', [ { point: 'execute' } ]) # same domain
      @loader.add(:hook, 'org.example.accounting', [ { point: 'execute' } ])
      @loader.add(:hook, 'com.example', [ { point: 'execute' } ])
      @loader.add(:hook, 'com.example.top', [ { point: 'execute' } ])
      @loader.add(:hook, 'mil.example.alpha', [ { point: 'execute' } ])
    end

    it 'returns all the domains in the loader' do

      ds = @loader.domains

      expect(ds).to eq(%w[
        com.example com.example.top
        mil.example.alpha
        org.example org.example.accounting ])
    end

    it 'returns all the subdomains of "org.example" in the loader' do

      ds = @loader.domains('org.example')

      expect(ds).to eq(%w[
        org.example org.example.accounting ])
    end
  end

  describe '#definitions' do

    before :each do

      @loader.add(:flow, 'net.example.flow0', "task 'alpha'")
      @loader.add(:flow, 'org.example.flow0', "task 'bravo'")
      @loader.add(:library, 'net.example.flow1', "task 'charly'")
      @loader.add(:library, 'org.example.flow1', "task 'delta'")
      @loader.add(:flow, 'org.example.one.flow2', "task 'echo'")
      @loader.add(:flow, 'net.example.two.flow2', "task 'fox'")
    end

    it 'returns all the definitions in the loader' do

      expect(
        @loader.definitions
      ).to eq(%w[
        net.example.flow0 net.example.flow1 net.example.two.flow2
        org.example.flow0 org.example.flow1 org.example.one.flow2
      ])
    end

    it 'returns all the definitions in the loader under "org.example"' do

      expect(
        @loader.definitions('org.example')
      ).to eq(%w[
        org.example.flow0 org.example.flow1 org.example.one.flow2
      ])
    end
  end

  context 'when empty environment' do

    describe '#variables' do

      it 'returns {}' do

        r = @loader.variables('nada')

        expect(r).to eq({})
      end
    end

    describe '#library' do

      it 'returns nil' do

        r = @loader.library('net.example')

        expect(r).to eq(nil)

        r = @loader.library('net.example', 'nada')

        expect(r).to eq(nil)
      end
    end

    describe '#tasker' do

      it 'returns nil' do

        r = @loader.tasker('net.example', 'alice')

        expect(r).to eq(nil)
      end
    end

    describe '#hooks' do

      it 'returns []' do

        r = @loader.hooks('org.example')

        expect(r).to eq([])
      end
    end

    describe '#domains' do

      it 'returns []' do

        expect(@loader.domains()).to eq([])
      end

      it 'returns [] for start="org.example"' do

        expect(@loader.domains('org.example')).to eq([])
      end
    end

    describe '#definitions' do

      it 'returns []' do

        expect(@loader.definitions('org.example')).to eq([])
      end

      it 'returns [] for start="org.example"' do

        expect(@loader.definitions('org.example')).to eq([])
      end
    end
  end
end

