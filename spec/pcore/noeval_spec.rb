
#
# specifying flor
#
# Sat Dec 24 20:31:59 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'noeval' do

    it 'leaves f.ret as is' do

      flor = %{
        sequence
          1
          noeval _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(1)
    end

    it "doesn't let its children getting evaluated" do

      flor = %{
        set a 1
        noeval
          set a 2
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end
  end

  describe '_' do

    it 'is equivalent to "noeval"' do

      flor = %{
        set a 1
        _
          set a 2
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(1)
    end

    it 'stands on its own' do

      flor = %{
        set a 1
        _
        set a 2
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq(2)

      expect(@executor.journal.size).to eq(17)
    end
  end
end

