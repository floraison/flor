
#
# specifying flor
#
# Sat May 27 11:57:25 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_pat_guard' do

    context '_pat_guard _' do

      it "doesn't match" do

        r = @executor.launch(
          %q{ _pat_guard _ },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq(nil)
      end
    end

    context '_pat_guard {name}' do

      it 'matches' do

        r = @executor.launch(
          %q{ _pat_guard x },
          payload: { 'ret' => 11 })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['_pat_binding']).to eq({ 'x' => 11 })
      end

      it 'may not match'
    end

    context '_pat_guard {name} {pattern}' do

      it 'matches'
      it 'may not match'
    end

    context '_pat_guard {name} {conditional}' do

      it 'matches'
      it 'may not match'
    end

    context '_pat_guard {name} {pattern} {conditional}' do

      it 'matches'
      it 'may not match'
    end

    context 'nested patterns' do

      it 'accepts a nested _pat_arr'
      it 'accepts a nested _pat_obj'
      it 'accepts a nested _pat_or'
      it 'accepts a nested _pat_guard'
    end
  end
end

