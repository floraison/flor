
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

      it 'slices' #do
#
#        r =
#          @executor.launch(%{
#            slice a 1 count: 2
#          },
#          vars: { 'a' => %w[ a b c d e f g ] })
#
#        expect(r['point']).to eq('terminated')
#        expect(r['payload']['ret']).to eq(%w[ b c ])
#      end
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

      it 'slices'
    end
  end

  describe 'index' do

    context 'with array' do

      it 'works'
    end

    context 'with string' do

      it 'works'
    end
  end
end

