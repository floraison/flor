
#
# specifying flor
#
# Wed Mar  1 20:56:07 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'case' do

    it 'has no effect if it has no children' do

      r = @executor.launch(
        %q{
          'before'
          case _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('before')
    end

    it 'triggers on match (1st)' do

      r = @executor.launch(
        %q{
          case 1 a: 'b'
            [ 0 1 2 ]; 'low'
            [ 3 4 5 ]; 'high'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('low')
    end

    it 'executes the clause for which there is a match' do

      r = @executor.launch(
        %q{
          case 4
            [ 0 1 2 ]; 'low'
            [ 3 4 5 ]; 'high'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('high')
    end

    it 'triggers on match (2nd)' do

      r = @executor.launch(
        %q{
          'nothing'
          case 6
            [ 0 1 2 ]; 'low'
            [ 3 4 5 ]; 'high'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('nothing')
    end

    it 'understands else' do

      r = @executor.launch(
        %q{
          'nothing'
          case 6
            [ 0 1 2 ]; 'low'
            [ 3 4 5 ]; 'high'
            else; 'over'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('over')
    end

    it "doesn't mind having no choice" do

      r = @executor.launch(
        %q{
          'nothing'
          case 6
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('nothing')
    end

    it "doesn't mind having nothing but a \"else\"" do

      r = @executor.launch(
        %q{
          'nothing'
          case 6
            else; 'over'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('over')
    end

    it 'makes up arrays' do

      r = @executor.launch(
        %q{
          'nothing'
          case 6
            [ 0 1 2 ]; 'low'
            6; 'high'
            else; 'over'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('high')
    end

    it 'works without ; ;-)' do

      r = @executor.launch(
        %q{
          'nothing'
          case 6
            [ 0 1 2 ]
            'low'
            [ 3 4 5 ]
            'high'
            else
            'over'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('over')
    end

    it 'considers f.ret by default' do

      r = @executor.launch(
        %q{
          2
          case
            [ 0 1 2 ]; 'low'
            6; 'high'
            else; 'over'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('low')
    end

    it 'considers f.ret by default (2)' do

      r = @executor.launch(
        %q{
          6
          case
            [ 0 1 2 ]; 'low'
            6; 'high'
            else; 'over'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('high')
    end
  end
end

