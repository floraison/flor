
#
# specifying flor
#
# Fri Feb 26 11:48:09 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '_key' do

    it 'sets the key string in its f.ret'
  end

  describe '_obj' do

    it 'works' do

      r = @executor.launch(%{ { a: 'A' } })

      expect(r['point']).to eq('terminated')
      expect(Flor.to_d(r['payload']['ret'])).to eq(%{
        { a: [ val, { t: sqstring, v: A }, 1, [] ] }
      }.strip)
    end
  end
end

