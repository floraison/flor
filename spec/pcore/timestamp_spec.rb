
#
# specifying flor
#
# Mon Aug 13 09:53:40 CEST 2018  Neyruz
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'timestamp' do

    it 'returns the current UTC timestamp' do

      r = @executor.launch(
        %q{
          timestamp _
        })

      n = Time.now.utc

      expect(r['point']).to eq('terminated')

      expect(
        r['payload']['ret']
      ).to match(
        /\A#{n.strftime('%Y-%m-%dT%H')}:\d{2}:\d{2}Z\z/
      )
    end
  end
end

