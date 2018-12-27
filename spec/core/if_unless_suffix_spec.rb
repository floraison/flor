
#
# specifying flor
#
# Thu Dec 27 11:45:10 JST 2018
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe '"if" as a suffix' do

    it 'works' do

      r = @executor.launch(
        %q{
          set f.l []
          push f.l 'a' if (length f.l) > 0
          push f.l 'b'
          push f.l 'c' if (length f.l) > 0
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ b c ])
    end
  end

  describe '"unless" as a suffix' do

    it 'works' do

      r = @executor.launch(
        %q{
          set f.l []
          push f.l 'a' unless (length f.l) > 0
          push f.l 'b'
          push f.l 'c' unless (length f.l) > 0
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ a b ])
    end
  end
end

