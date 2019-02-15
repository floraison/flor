
#
# specifying flor
#
# Thu Feb 14 12:56:01 JST 2019  Basset Cafe
#

require 'spec_helper'


describe Flor::HashLoader do

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

  describe '#variables' do

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

      @loader.add(:libraries, 'net.example.flow1', "task 'nathalie'")
      @loader.add(:libraries, 'org.example.flow1', "task 'oskar'")
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

#    {
#      [ '', 'alice' ] => [
#        'basic alice', %w[ description a _path root ] ],
#
#      [ 'net.example', 'alice' ] => [
#        'basic alice', %w[ description a _path root ] ],
#
#      [ 'org.example', 'alice' ] => [
#        'org.example alice', %w[ description ao _path root ] ],
#
#      [ '', 'bob' ] => [
#        nil ],
#
#      [ 'net.example', 'bob' ] => [
#        'usr net.example bob', %w[ description ubn _path root ] ],
#
#      [ 'org.example', 'bob' ] => [
#        'org.example bob', %w[ description bo _path root ] ],
#
#      [ 'org.example.bob', nil ] => [
#        'org.example bob', %w[ description bo _path root ] ],
#
#    }.each do |ks, (desc, keys)|
#
#      it "loads tasker conf at #{ks.inspect}" do
#
#        t = @loader.tasker(*ks)
#
#        if desc
#          expect(t['description']).to eq(desc)
#          expect(t.keys).to eq(keys)
#        else
#          expect(t).to eq(nil)
#        end
#      end
#    end

#    {
#
#      [ 'com.example.tasker', nil ] => '/cet/dot.json',
#      [ 'com.example', 'tasker' ] => '/cet/dot.json',
#      [ 'com.example.alpha.tasker', nil ] => '/usr/ceat/dot.json',
#      [ 'com.example.alpha', 'tasker' ] => '/usr/ceat/dot.json',
#      [ 'com.example.bravo.tasker', nil ] => '/usr/cebt/flor.json',
#      [ 'com.example.bravo', 'tasker' ] => '/usr/cebt/flor.json',
#      [ 'com.example.charly', 'tasker' ] => '/cect.json',
#
#    }.each do |ks, desc|
#
#      it "loads the domain tasker conf at #{ks.inspect}" do
#
#        tc = @loader.tasker(*ks)
#
#        expect(tc['description']).to eq(desc)
#      end
#    end

#    it 'loads a tasker conf {name}.json' do
#
#      tc = @loader.tasker('org.example', 'charly')
#      expect(tc['description']).to eq('org.example charly')
#
#      expect(tc['_path']).to point_to(
#        'envs/uspec_loader/lib/taskers/org.example/charly.json')
#    end

#    {
#
#      [ 'mil.example', 'staff' ] => [
#        'mil.example.staff',
#        nil ],
#      [ 'mil.example.ground', 'staff' ] => [
#        'mil.example.ground.staff',
#        nil ],
#      [ 'mil.example.air', 'command' ] => [
#        'mil.example.air.command',
#        nil ],
#      [ 'mil.example.air.tactical', 'command' ] => [
#        'mil.example.air.command',
#        'envs/uspec_loader/usr/mil.example/lib/taskers/air.json' ],
#
#    }.each do |ks, (desc, path)|
#
#      it "loads the do.main.json tasker conf at #{ks.inspect}" do
#
#        tc = @loader.tasker(*ks)
#
#        expect(tc['description']).to eq(desc)
#        expect(tc['_path']).to point_to(path) if path
#      end
#    end

#    it 'loads a tasker array configuration do.ma.in.json' do
#
#      tc = @loader.tasker('mil.example.air.tactical', 'intel')
#
#      expect(tc.size).to eq(2)
#
#      expect(tc[0]['point']).to eq('task')
#      expect(tc[1]['point']).to eq('detask')
#
#      expect(tc[0]['_path']).to point_to(
#        'envs/uspec_loader/usr/mil.example/lib/taskers/air.json')
#      expect(tc[1]['_path']).to point_to(
#        'envs/uspec_loader/usr/mil.example/lib/taskers/air.json')
#    end

#    it 'uses the message when loading the tasker configuration' do
#
#      tc = @loader.tasker(
#        'edu.example', 'echo',
#        { 'payload' => { 'flavour' => 'vanilla' } })
#
#      expect(tc['description']).to eq(
#        'edu.example echo')
#      expect(tc['class']).to eq(
#        'Edu::Example::Taskers::Vanilla')
#      expect(tc['_path']).to match(
#        /\/envs\/uspec_loader\/lib\/taskers\/edu\.example\/echo\/dot\.json\z/)
#      expect(tc['root']).to eq(
#        'envs/uspec_loader/lib/taskers/edu.example/echo')
#    end
  end

  describe '#hooks' do

#    it 'returns the sum of the hooks for a domain' do
#
#      hooks = @loader.hooks('org.example')
#
#      expect(hooks.size).to eq(3)
#
#      expect(hooks[0]['point'])
#        .to eq('execute')
#      expect(hooks[0]['require'])
#        .to eq('xyz/my_hooks.rb')
#      expect(hooks[0]['class'])
#        .to eq('Xyz::MyExecuteHook')
#      expect(hooks[0]['_path'])
#        .to point_to('envs/uspec_loader/lib/hooks/dot.json:0')
#
#      expect(hooks[1]['point'])
#        .to eq('terminated')
#      expect(hooks[1]['require'])
#        .to eq('xyz/my_hooks.rb')
#      expect(hooks[1]['class'])
#        .to eq('Xyz::MyGenericHook')
#      expect(hooks[1]['_path'])
#        .to point_to('envs/uspec_loader/lib/hooks/dot.json:1')
#
#      expect(hooks[2]['point'])
#        .to eq('execute')
#      expect(hooks[2]['require'])
#        .to eq('xyz/oe_hooks.rb')
#      expect(hooks[2]['class'])
#        .to eq('Xyz::OeExecuteHook')
#      expect(hooks[2]['_path'])
#        .to point_to('envs/uspec_loader/lib/hooks/org.example.json:0')
#    end

#    it 'loads from hooks.json' do
#
#      hooks = @loader.hooks('mil.example')
#
#      expect(hooks.size).to eq(3)
#
#      expect(hooks[0]['point'])
#        .to eq('execute')
#      expect(hooks[0]['require'])
#        .to eq('xyz/my_hooks.rb')
#      expect(hooks[0]['class'])
#        .to eq('Xyz::MyExecuteHook')
#      expect(hooks[0]['_path'])
#        .to point_to('envs/uspec_loader/lib/hooks/dot.json:0')
#
#      expect(hooks[1]['point'])
#        .to eq('terminated')
#      expect(hooks[1]['require'])
#        .to eq('xyz/my_hooks.rb')
#      expect(hooks[1]['class'])
#        .to eq('Xyz::MyGenericHook')
#      expect(hooks[1]['_path'])
#        .to point_to('envs/uspec_loader/lib/hooks/dot.json:1')
#
#      expect(hooks[2]['point'])
#        .to eq('receive')
#      expect(hooks[2]['require'])
#        .to eq('xyz/me_hooks.rb')
#      expect(hooks[2]['class'])
#        .to eq('Xyz::MeReceiveHook')
#      expect(hooks[2]['_path'])
#        .to point_to('envs/uspec_loader/usr/mil.example/lib/hooks/hooks.json:0')
#    end
  end
end

