
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

  describe '_arr' do

    it 'works' do

      r = @executor.launch(%{ [ 1, 2, "trois" ] })

      expect(r['point']).to eq('terminated')
      expect(Flor.to_d(r['payload']['ret'])).to eq(%{
        [ 1, 2, [ val, { t: dqstring, v: trois }, 1, [] ] ]
      }.strip)
    end
  end
end

