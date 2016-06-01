
#
# specifying flor
#
# Thu May 26 21:15:18 JST 2016
#

require 'spec_helper'


describe 'Flor texecutor' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'journal' do

    it 'stays nil by default' do

      flon = %{
        sequence
      }

      r = @executor.launch(flon, journal: false)

      expect(r['point']).to eq('terminated')

      expect(@executor.journal).to eq(nil)
    end

    it 'is kept if journal: true' do

      flon = %{
        sequence
      }

      r = @executor.launch(flon, journal: true)

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal.collect { |m| m['point'] }
      ).to eq(%w[
        execute receive terminated
      ])
    end

    class MyJournal
      def initialize
        @msgs = []
      end
      def <<(m)
        @msgs << m
      end
      def to_a
        @msgs
      end
    end

    it 'accepts a custom journal' do

      j = MyJournal.new

      flon = %{
        sequence
      }

      r = @executor.launch(flon, journal: j)

      expect(r['point']).to eq('terminated')

      expect(
        j.to_a.collect { |m| m['point'] }
      ).to eq(%w[
        execute receive terminated
      ])
    end
  end
end

