
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

      flor = %{
        'before'
        case _
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('before')
    end

    it 'triggers on match (1st)' do

      flor = %{
        case 1 a: 'b'
          [ 0 1 2 ];; 'low'
          [ 3 4 5 ];; 'high'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('low')
    end

    it 'executes the clause for which there is a match' do

      flor = %{
        case 4
          [ 0 1 2 ];; 'low'
          [ 3 4 5 ];; 'high'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('high')
    end

    it 'triggers on match (2nd)' do

      flor = %{
        'nothing'
        case 6
          [ 0 1 2 ];; 'low'
          [ 3 4 5 ];; 'high'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('nothing')
    end

    it 'understands else' do

      flor = %{
        'nothing'
        case 6
          [ 0 1 2 ];; 'low'
          [ 3 4 5 ];; 'high'
          else;; 'over'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('over')
    end

    it 'makes up arrays' do

      flor = %{
        'nothing'
        case 6
          [ 0 1 2 ];; 'low'
          6;; 'high'
          else;; 'over'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('high')
    end

    it 'works without ;; ;-)' do

      flor = %{
        'nothing'
        case 6
          [ 0 1 2 ]
          'low'
          [ 3 4 5 ]
          'high'
          else
          'over'
      }

      r = @executor.launch(flor)

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('over')
    end

    context 'flattening' do

#      before :all do
#
#        @flo = %{
#          case f.x
#            [ 0 1 2 ]
#              'a'
#            3
#              'b'
#              'c'
#            [ 4 5 ]
#              concurrence
#                'd'
#                'e'
#            6;; 'f'
#            else
#              'g'
#              'h'
#        }
#      end
#
#      [
#        [ 1, 'a' ],
#        [ 3, 'c' ],
#        [ 4, 'd' ],
#        [ 6, 'f' ],
#        [ 7, 'h' ]
#      ].each_with_index do |(x, ret), i|
#
#        it "works (#{i})" do
#
#          r = @executor.launch(@flo, payload: { 'x' => x }, wait: true)
#          expect(r['point']).to eq('terminated')
#          expect(r['payload']['ret']).to eq(ret)
#        end
#      end
#
#      it 'is ok with vars as arrays' do
#
#        flor = %{
#          set r []
#          set a [ 0 1 2 ]
#          define b start
#            [ start ]
#          case 1
#            a
#            push r 'a'
#            b 3
#            push r 'b'
#          case 1
#            a
#              push r 'aa'
#            b 3
#              push r 'bb'
#          case 3
#            a
#              push r 'aaa'
#            b 3
#              push r 'bbb'
#        }
#
#        r = @executor.launch(flor, wait: true)
#        expect(r['vars']['r']).to eq(%w[ a aa bbb ])
#      end

#      before :each do
#
#        flon = %{ case 1; x;; y }
#        ms = @executor.launch(
#          flon,
#          vars: {
#            'a0' => [ 0, 1, 2 ]
#          },
#          until_after: '0_0 execute')
#        @case = Flor::Pro::Case.new(@executor, nil, ms.first)
#        class << @case
#          def do_flatten(s)
#            @node['tree'] = Flor::Lang.parse(s)
##pp @node['tree']
#            unatt_unkeyed_children
#            flatten
#            @node['tree']
#          end
#        end
#      end
#
#      it 'flattens after a literal array' do
#
#        ft =
#          @case.do_flatten(%{
#            case 1
#              [ 1 2 ]
#                x
#          })
#        expect(ft[1]).to eq(
#          [["_num", 1, 2],
#           ["_arr", [["_num", 1, 3], ["_num", 2, 3]], 3],
#            ["x", [], 4]]
#        )
#      end
#
#      it 'flattens after a literal number' do
#
#        ft =
#          @case.do_flatten(%{
#            case 1
#              1
#                x
#          })
#        expect(ft[1]).to eq(
#          [["_num", 1, 2],
#           ["_arr", [["_num", 1, 3], ["_num", 2, 3]], 3],
#            ["x", [], 4]]
#        )
#      end
    end
  end
end

