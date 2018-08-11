
#
# specifying flor
#
# Thu Aug  9 10:28:59 CEST 2018  Neyruz
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'slice' do

    context 'with array' do

      {

        '1, -1' => %w[ b c d e f g ],
        'from: 1, to: -1' => %w[ b c d e f g ],
        '1, count: 2' => %w[ b c ],

      }.each do |args, ret|

        it "slices #{args}" do

          r =
            @executor.launch(%{
              a
              slice #{args}
            },
            vars: { 'a' => %w[ a b c d e f g ] })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(ret)
        end
      end

      it 'slices' do

        r =
          @executor.launch(%{
            [ (slice a 1 count: 2)
              (slice 1 a count: 2)
              (slice 1 count: 2 a) ]
          },
          vars: { 'a' => %w[ a b c d e f g ] })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq([ %w[ b c ] ] * 3)
      end
    end

    context 'with string' do

      {

        '1, -1' => 'bcdefg',
        'from: 1, to: -1' => 'bcdefg',
        '1, count: 2' => 'bc',

      }.each do |args, ret|

        it "slices #{args}" do

          r =
            @executor.launch(%{
              s
              slice #{args}
            },
            vars: { 's' => 'abcdefg' })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(ret)
        end
      end

      it 'slices' do

        r =
          @executor.launch(%{
            [ (slice s 1 count: 2)
              (slice 1 s count: 2)
              (slice 1 count: 2 s) ]
          },
          vars: { 's' => 'abcdefg' })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq([ 'bc' ] * 3)
      end
    end
  end

  describe 'index' do

    context 'with array' do

      {

        '2' => 'c',
        ',-3' => 'e',
        '(-3)' => 'e',
        'at: -3' => 'e',
        '100' => '',

      }.each do |args, ret|

        it "indexes #{args}" do

          r =
            @executor.launch(%{
              a; index #{args}
            },
            vars: { 'a' => %w[ a b c d e f g ] })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(ret)
        end
      end
    end

    context 'with string' do

      {

        '2' => 'c',
        ',-3' => 'e',
        '(-3)' => 'e',
        'at: -3' => 'e',
        '100' => '',

      }.each do |args, ret|

        it "indexes #{args}" do

          r =
            @executor.launch(%{
              a; index #{args}
            },
            vars: { 'a' => 'abcdefg' })

          expect(r['point']).to eq('terminated')
          expect(r['payload']['ret']).to eq(ret)
        end
      end

      it 'indexes' do

        r =
          @executor.launch(%{
            [ (index s 2) (index 2 s) ]
          },
          vars: { 's' => 'abcdefg' })

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(%w[ c c ])
      end
    end
  end
end

