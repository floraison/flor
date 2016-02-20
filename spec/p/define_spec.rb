
#
# specifying flor
#
# Sat Feb 20 20:57:16 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'define' do

    it 'binds a function' do

      rad = %{
        define sum a, b
          +
            a
            b
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['vars']).to eq({ 'sum' => r['payload']['ret'] })

      expect(
        r['payload']['ret']
      ).to eq(
        [ 'val',
          { 't' => 'function', 'v' => { 'nid' => '0', 'vnid' => '0' } },
          2,
          []
        ]
      )
    end
  end
end

