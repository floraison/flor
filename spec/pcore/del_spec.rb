
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

#    it 'deletes multiple variables' do
#
#      r = @executor.launch(
#        %q{ del a v.b },
#        variables: { 'a' => 1, 'b' => 2, 'c' => 3 })
#
#      expect(r).to have_terminated_as_point
#      expect(r['from']).to eq('0')
#      expect(r['payload']).to eq({ 'ret' => 2 })
#      expect(r['vars']).to eq({ 'c' => 3 })
#    end

    it 'deletes a field'

    it 'deletes a variable deeply'
    it 'deletes a field deeply'

    it 'fails when it cannot delete a variable deeply'
    it 'fails when it cannot delete a field deeply'

    it 'deletes a local variable lv.a'
  end
end

