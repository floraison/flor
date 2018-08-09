
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

    context 'array' do

      {

        [ 1, -1 ] => %w[ b c d e f g ],

      }.each do |args, ret|

        it "#{args.inspect} to #{ret}" do

          args =
            case args
            when Array then args.collect(&:to_s).join(', ')
            else args.collect { |k, v| "#{k}: #{v}" }.join(', ')
            end

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
    end

    context 'string' do

      it 'works'
    end
  end

  describe 'index' do

    context 'array' do

      it 'works'
    end

    context 'string' do

      it 'works'
    end
  end
end

