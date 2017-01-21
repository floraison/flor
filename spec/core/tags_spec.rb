
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

      flor = %{
        sequence tag: 'aa'
          sequence tag: 'bb'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:aa
        receive:0:
        execute:0_1:
        execute:0_1_0:
        execute:0_1_0_0:
        receive:0_1_0:
        execute:0_1_0_1:
        receive:0_1_0:
        entered:0_1:bb
        receive:0_1:
        receive:0:
        left:0_1:bb
        receive::
        left:0:aa
        terminated::
      ].join("\n"))
    end
  end

  describe 'the tags attribute' do

    it 'lets multiple tags be flagged at once' do

      flor = %{
        sequence tag: 'aa', tag: 'bb'
          sequence tags: [ 'cc', 'dd' ]
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:aa
        receive:0:
        execute:0_1:
        execute:0_1_0:
        receive:0_1:
        execute:0_1_1:
        receive:0_1:
        entered:0:bb
        receive:0:
        execute:0_2:
        execute:0_2_0:
        execute:0_2_0_0:
        receive:0_2_0:
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
      ].join("\n"))
    end

    it 'fails on non-string attributes' do

      flor = %{
        sequence tag: aa
          1
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('failed')
    end

    it 'accepts procs as tags' do

      flor = %{
        sequence tag: sequence
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .inject([]) { |a, m|
            next a unless m['point'] == 'entered'
            a << [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':')
            a
          }.join("\n")
      ).to eq(%w[
        entered:0:sequence
      ].join("\n"))
    end

    it 'accepts functions as tags' do

      flor = %{
        define x; _
        sequence tag: x
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .inject([]) { |a, m|
            next a unless m['point'] == 'entered'
            a << [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':')
            a
          }.join("\n")
      ).to eq(%w[
        entered:0_1:x
      ].join("\n"))
    end

    it 'accepts functions as tags (closure)' do

      flor = %{
        define make_tag x
          def; sequence tag: x
        define t1; _
        set v; make_tag t1
        v _
        v _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .inject([]) { |a, m|
            next a unless m['point'] == 'entered'
            a << [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':')
            a
          }.join("\n")
      ).to eq(%w[
        entered:0_0_2_0-2:t1
        entered:0_0_2_0-3:t1
      ].join("\n"))
    end
  end
end

