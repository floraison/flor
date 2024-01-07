
#
# specifying flor
#
# Sat Apr  2 11:18:12 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'cond' do

    it 'has no effect if it has no children' do

      r = @executor.launch(
        %q{
          push f.l 0
          cond _
          push f.l 1
        },
        payload: { 'l' => [] })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(nil)
      expect(r['payload']['l']).to eq([ 0, 1 ])
    end

    it 'triggers' do

      r = @executor.launch(
        %q{
          set a 4
          cond
            a < 4
            "less than four"
            a < 7
            "less than seven"
            a < 10
            "less than ten"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('less than seven')
    end

    it 'has no effect when there is no match' do

      r = @executor.launch(
        %q{
          7
          set a 10
          cond
            a < 4 ; "less than four"
            a < 7 ; "less than seven"
            a < 10 ; "less than ten"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
    end

    it 'defaults to the "else" if present' do

      r = @executor.launch(
        %q{
          set a 11
          cond
            a < 4 ; "less than four"
            a < 7 ; "less than seven"
            else ; "ten or bigger"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('ten or bigger')
    end

    it 'does not mind an else followed by nothing' do

      r = @executor.launch(
        %q{
          7
          set a 11
          cond
            a < 4 ; "less than four"
            a < 7 ; "less than seven"
            else
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
    end

    it 'does not mind "else" being aliased to "sequence"' do

      r = @executor.launch(
        %q{
          set else sequence
          set a 11
          cond
            a < 4 ; "less than four"
            a < 7 ; "less than seven"
            else ; "ten or more"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('ten or more')
    end

    it 'does not mind "else" being aliased to "sequence" (take 2)' do

      r = @executor.launch(
        %q{
          set else sequence
          set a 6
          cond
            a < 4 ; "less than four"
            a < 7 ; "less than seven"
            else ; "ten or more"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('less than seven')
    end

    it 'is OK with a true instead of an "else"' do

      # pipe or semicolon, trying with pipe for this one

      r = @executor.launch(
        %q{
          set a 12
          cond
            a < 4 | "less than four"
            a < 7 | "less than seven"
            true | "ten or bigger"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('ten or bigger')
    end

    it 'does not mind a true followed by nothing' do

      r = @executor.launch(
        %q{
          7
          set a 12
          cond
            a < 4 ; "less than four"
            a < 7 ; "less than seven"
            true
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(7)
    end
  end
end

