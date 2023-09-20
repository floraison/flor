
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

    it 'works (2)' do

      r = @executor.launch(
        %q{
          set f.l []
          push f.l 'a' if > (length f.l) 0
          push f.l 'b'
          push f.l 'c' if > (length f.l) 0
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ b c ])
    end

    it 'gets skipped by on_ setters' do

      @executor.launch(
        %q{
          sequence
            on error if true
              push f.l err.msg
            stall _
        })

      expect(@executor.execution['nodes'].keys).to eq(%w[ 0 0_1 ])

      oe = @executor.execution['nodes']['0']['on_error']
      expect(oe[0][0]).to eq([ '*' ])
      expect(oe[0][1][0]).to eq('_func')
    end

    it "can be a suffix to a sequence 'block'" do

      r = @executor.launch(
        %q{
          set f.l []
          push f.l 'a'
          sequence if > (length f.l) 1
            push f.l 'b'
            push f.l 'c'
          push f.l 'd'
          sequence if > (length f.l) 1
            push f.l 'e'
            push f.l 'f'
          push f.l 'g'
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['l']).to eq(%w[ a d e f g ])
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

