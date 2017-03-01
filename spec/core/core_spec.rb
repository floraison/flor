
#
# specifying flor
#
# Tue Mar 22 06:44:32 JST 2016
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a procedure on its own' do

    it 'is returned' do

      flor = %{
        sequence
      }

      r = @executor.launch(flor)

      expect(
        r['point']
      ).to eq('terminated')
      expect(
        r['payload']['ret']
      ).to eq([ '_proc', { 'proc' => 'sequence' }, -1 ])
    end
  end

  describe 'a procedure with a least a child' do

    it 'is executed' do

      flor = %{
        sequence _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end
  end

  context 'a postfix conditional' do

    it 'is a call wrapped' do
      #
      # `break if a == 3`
      # is equivalent to
      # ```
      # if a == 3
      #   break _
      # ```
      # (note the underscore)

      flor = %{
        set a 3
        until true
          break if a == 3
          set a (+ a 1)
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
    end
  end

  describe 'a "terminated" message' do

    it 'has a source message "sm"' do

      flor = %{
        sequence _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['m']).to eq(5)
      expect(r['sm']).to eq(4)
    end
  end

  describe 'non-symbols att' do

    it 'is accepted' do

      flor = %{
        set v0 'ag'
        set v1 'tag'
        sequence (+ "t" v0): 'xx'
        sequence 'tag': 'yy'
        sequence v1: 'zz'
        sequence tag: 'aa'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .select { |m| m['point'] == 'left' }
          .map { |m| [ m['point'], m['nid'], m['tags'].join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        left:0_2:xx
        left:0_3:yy
        left:0_4:zz
        left:0_5:aa
      ].join("\n"))
    end
  end
end

