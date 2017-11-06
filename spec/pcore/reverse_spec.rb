
#
# specifying flor
#
# Thu Jun 15 15:56:45 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'reverse' do

    it 'reverses the f.ret array' do

      r = @executor.launch(
        %q{
          [ 1, 2, 3 ]
          reverse _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 3, 2, 1 ])
    end

    it 'reverses arrays' do

      r = @executor.launch(
        %q{
          reverse [ 1, 2, 3 ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq([ 3, 2, 1 ])
    end

    it 'reverses strings' do

      r = @executor.launch(
        %q{
          reverse 'melimelo'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('olemilem')
    end

    it 'does not reverse attributes' do

      r = @executor.launch(
        %q{
          [
            (reverse 'onegin' tag: 'a')
            ('pushkin'; reverse tag: 'b')
          ]
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(%w[ nigeno nikhsup ])
    end

    it 'fails if there is nothing to reverse' do

      r = @executor.launch(
        %q{
          reverse _
        })

      expect(r['point']
        ).to eq('failed')
      expect(r['error']['kla']
        ).to eq('Flor::FlorError')
      expect(r['error']['msg']
        ).to eq('Found no argument that could be reversed')
      expect(r['error']['lin']
        ).to eq(2)
    end
  end
end

