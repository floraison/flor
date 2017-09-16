
#
# specifying flor
#
# Thu May 11 12:01:58 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'and' do

    it 'returns true if empty' do

      r = @executor.launch(
        %q{
          and _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end

    it 'returns true if all the children yield true' do

      r = @executor.launch(
        %q{
          and true true
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end

    it 'returns false if a child yields false' do

      r = @executor.launch(
        %q{
          and false true
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
    end

    it 'returns false as soon as possible' do

      r = @executor.launch(
        %q{
          and false true
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)

      expect(
        @executor.journal
          .find { |m|
            m['point'] == 'execute' && m['tree'][0, 2] == [ '_boo', true ] }
      ).to eq(
        nil
      )
    end
  end

  describe 'or' do

    it 'returns false if empty' do

      r = @executor.launch(
        %{
          or _
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(false)
    end

    it 'returns true as soon as possible' do

      r = @executor.launch(
        %q{
          or true false
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)

      expect(
        @executor.journal
          .find { |m|
            m['point'] == 'execute' && m['tree'][0, 2] == [ '_boo', false ] }
      ).to eq(
        nil
      )
    end
  end

  describe 'and vs or' do

    it 'gives higher precedence to "and"'# do
#
#      r = @executor.launch(
#        %q{
#          and true or false 2 FIXME
#        })
#
#      expect(r['point']).to eq('terminated')
#      expect(r['payload']['ret']).to eq(false)
#    end
  end
end

