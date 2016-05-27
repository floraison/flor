
#
# specifying flor
#
# Thu May 26 21:03:50 JST 2016
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'the tag attribute' do

    it 'induces messages to be tagged' do

      flon = %{
        sequence tag: 'aa'
          sequence tag: 'bb'
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .collect { |m| [ m['point'], m['nid'], m['tag'].to_s ].join(':') }
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:aa
        receive:0:
        execute:0_1:
        execute:0_1_0:
        execute:0_1_0_1:
        receive:0_1_0:
        entered:0_1:bb
        receive:0_1:
        receive:0:
        receive::
        terminated::
      ])
    end
  end
end

