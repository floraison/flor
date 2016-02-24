
#
# specifying flor
#
# Sat Feb 20 20:57:16 JST 2016
#

require 'spec_helper'


describe 'Flor a-to-z' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'a procedure reference' do

    it 'returns the referenced procedure' do

      rad = %{
        sequence
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')

      expect(Flor.to_d(r['payload']['ret'])).to eq(%{
        [ val, { t: procedure, v: { n: sequence } }, 2, [] ]
      }.strip)
    end
  end

  describe 'a function reference' do

    it 'returns the referenced function' do

      rad = %{
        sequence
          define sum a, b
            # empty
          sum
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')

      expect(Flor.to_d(r['payload']['ret'])).to eq(%{
        [ val, { t: function, v: { nid: 0_0, vnid: "0" } }, 3, [] ]
      }.strip)
    end
  end

  describe 'a function call' do

    it 'works' do

      rad = %{
        sequence
          define sum a, b
            +
              a
              b
          sum 1 2
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(3)
    end
  end
end

