
#
# specifying flor
#
# Sun Nov 25 11:55:00 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'sort' do

    context 'without a function' do

      it 'sorts' do

        r = @executor.launch(
          %q{
            sort [ 0 7 1 5 3 4 2 6 ]
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq([ 0, 1, 2, 3, 4, 5, 6, 7 ])
      end

      it 'sorts heterogeneous arrays' do

        r = @executor.launch(
          %q{
            sort [ 0 null 1.1 true "false" [ 0 1 ] { c: 2 } ]
          })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['ret']
        ).to eq([
          0, 1.1, [ 0, 1 ], "false", nil, true, { 'c' => 2 }
        ])
      end

      it 'sorts arrays of objects' do

        r = @executor.launch(
          %q{
            sort [ { age: 99 } { age: 33 } ]
          })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['ret']
        ).to eq([
          { 'age' => 33 }, { 'age' => 99 }
        ])
      end

      it 'sorts arrays of arrays' do

        r = @executor.launch(
          %q{
            sort [ [ 'zzz' ] [ 'bbb' ] ]
          })

        expect(r['point']).to eq('terminated')

        expect(
          r['payload']['ret']
        ).to eq([
          [ 'bbb' ], [ 'zzz' ]
        ])
      end

      it 'sorts the incoming f.ret if necessary' do

        r = @executor.launch(
          %q{
            [ 0 7 1 5 3 4 2 6 ]
            sort tag: 'x'
          })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq([ 0, 1, 2, 3, 4, 5, 6, 7 ])
      end
    end

    context 'with a function' do

      it 'sorts (boolean function)'# do
#
#        r = @executor.launch(
#          %q{
#            [
#              { name: 'Alice', age: 33, function: 'ceo' }
#              { name: 'Bob', age: 44, function: 'cfo' }
#              { name: 'Charly', age: 27, function: 'cto' }
#            ]
#            sort (def a b \ > a.age b.age)
#          })
#
#        expect(r['point']).to eq('terminated')
#
#        expect(
#          r['payload']['ret']
#        ).to eq([
#          { 'name' => 'Bob', 'age' => 44, 'function' => 'cfo' },
#          { 'name' => 'Alice', 'age' => 33, 'function' => 'ceo' },
#          { 'name' => 'Charly', 'age' => 27, 'function' => 'cto' },
#        ])
#      end

      it 'sorts (integer function)'# do
#
#        r = @executor.launch(
#          %q{
#            [
#              { name: 'Alice', age: 33, function: 'ceo' }
#              { name: 'Bob', age: 44, function: 'cfo' }
#              { name: 'Charly', age: 27, function: 'cto' }
#            ]
#            sort (def a b \ - a.age b.age)
#          })
#
#        expect(r['point']).to eq('terminated')
#
#        expect(
#          r['payload']['ret']
#        ).to eq([
#          { 'name' => 'Bob', 'age' => 44, 'function' => 'cfo' },
#          { 'name' => 'Alice', 'age' => 33, 'function' => 'ceo' },
#          { 'name' => 'Charly', 'age' => 27, 'function' => 'cto' },
#        ])
#      end
    end
  end
end

