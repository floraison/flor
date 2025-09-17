
#
# specifying flor
#
# Wed Sep 17 11:41:22 JST 2025
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'del' do

    it 'has no effect on its own' do

      r = @executor.launch(%q{ del _ })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'ret' => nil })
      expect(r['vars'].has_key?('_')).to be(false)
    end

    it 'deletes a variable' do

      r = @executor.launch(
        %q{ del a; del v.b },
        variables: { 'a' => 1, 'b' => 2, 'c' => 3 })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'ret' => 2 })
      expect(r['vars']).to eq({ 'c' => 3 })
    end

    it 'deletes multiple variables' do

      r = @executor.launch(
        %q{ del a v.b },
        variables: { 'a' => 1, 'b' => 2, 'c' => 3 })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'ret' => 2 })
      expect(r['vars']).to eq({ 'c' => 3 })
    end

    it 'deletes a field' do

      r = @executor.launch(
        %q{ del f.a },
        payload: { 'a' => 'alpha', 'b' => 'bravo' })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'b' => 'bravo', 'ret' => 'alpha' })
      expect(r['vars']).to eq({})
    end

    it 'deletes a variable deeply' do

      r = @executor.launch(
        %q{ del v.a.1 },
        variables: { 'a' => [ 0, 1, 2 ] })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'ret' => 1 })
      expect(r['vars']).to eq({ 'a' => [ 0, 2 ] })
    end

    it 'deletes a field deeply' do

      r = @executor.launch(
        %q{ del f.a.1 },
        payload: { 'a' => [ 0, 1, 2 ] })

      expect(r).to have_terminated_as_point
      expect(r['from']).to eq('0')
      expect(r['payload']).to eq({ 'a' => [ 0, 2 ], 'ret' => 1 })
      expect(r['vars']).to eq({})
    end

    it 'fails when it cannot delete a variable deeply' do

      r = @executor.launch(%q{ del v.a.1 })

      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('KeyError')
      expect(r['error']['msg']).to match(/\Avariable "a" not found\z/)
    end

    it 'fails when it cannot delete a field deeply' do

      r = @executor.launch(%q{ del f.a.1 })

      expect(r['point']).to eq('failed')
      expect(r['error']['kla']).to eq('KeyError')
      expect(r['error']['msg']).to eq('found nothing at "a" ("1" remains)')
    end

    it 'deletes a local variable lv.a'
  end
end

