
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
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
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
        left:0_1:bb
        receive::
        left:0:aa
        terminated::
      ])
    end
  end

  describe 'the tags attribute' do

    it 'lets multiple tags be flagged at once' do

      flon = %{
        sequence tag: 'aa', tag: 'bb'
          sequence tags: [ 'cc', 'dd' ]
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:aa
        receive:0:
        execute:0_1:
        execute:0_1_1:
        receive:0_1:
        entered:0:bb
        receive:0:
        execute:0_2:
        execute:0_2_0:
        execute:0_2_0_1:
        execute:0_2_0_1_0:
        receive:0_2_0_1:
        execute:0_2_0_1_1:
        receive:0_2_0_1:
        receive:0_2_0:
        entered:0_2:cc,dd
        receive:0_2:
        receive:0:
        left:0_2:cc,dd
        receive::
        left:0:aa,bb
        terminated::
      ])
    end

    it 'fails on non-string attributes' do

      flon = %{
        sequence tag: aa
          1
      }

      r = @executor.launch(flon)

      expect(r['point']).to eq('failed')
    end
  end
end

