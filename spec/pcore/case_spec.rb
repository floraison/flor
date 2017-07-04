
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

    it 'lets the possibility array sees the original, outer, f.ret' do

      r = @executor.launch(
        %q{
          7
          case (+ 3 4)
            5; 'cinq'
            [ f.ret ]; 'sept'
            6; 'six'
            else; 'je ne sais pas'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('sept')
    end

    it 'lets the then-tree sees the original, outer, f.ret' do

      r = @executor.launch(
        %q{
          "six"
          case 6
            5; 'cinq'
            7; 'sept'
            6; "six $(f.ret|u)"
            else; 'je ne sais pas'
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('six SIX')
    end

    it 'does not eval then-branches as conditionals' do

      r = @executor.launch(
        %q{
          case 6
            5; 6
            7; 8
            else; 9
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(9)
    end

    context 'and regexes' do

      it 'does not match if the argument is not a string' do

        r = @executor.launch(
          %q{
            case 6
              /a+/; 'as'
              /b+/; 'bs'
              else; 'else'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('else')
      end

      it 'matches' do

        r = @executor.launch(
          %q{
            case 'ovomolzin'
              /a+/; 'ahahah'
              /o+/; 'ohohoh'
              else; 'else'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('ohohoh')
      end

      it 'matches when arrayed regexes' do

        r = @executor.launch(
          %q{
            case 'ovomolzin'
              /a+/; 'ahahah'
              [ /u+/, /o+/ ]; 'ohohoh'
              else; 'else'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('ohohoh')
      end

      it 'does not match' do

        r = @executor.launch(
          %q{
            case 'ubuntu'
              /a+/; 'ahahah'
              /o+/; 'ohohoh'
              else; 'else'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq('else')
      end
    end
  end
end

