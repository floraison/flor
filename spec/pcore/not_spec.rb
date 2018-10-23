
#
# specifying flor
#
# Thu May 11 11:03:25 JST 2017  圓さんの家
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'not' do

    {

      %q{ not _ } => true,
      %q{ not true } => false,
      %q{ not false } => true,
      %q{ not 0 } => false,
      %q{ not 1 } => false,
      %q{ not 'false' } => false,
      %q{ not 'true' } => false,
      %q{ not true false } => true,

      'not(false)' => true,
      'not(false) true' => false,
      'not(true)' => false,
      '(not false)' => true,
      '(not true)' => false,

    }.test_each(self)

    it 'negates its last child' do

      r = @executor.launch(
        %q{
          not
            true
            false
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end

    it 'negates its last child (one-liner)' do

      r = @executor.launch(
        %q{ not \ true | false })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq(true)
    end

    context 'with "and" and "or"' do

      {

        'and (not false) (not true)' => false,
        'and (not false) (not false)' => true,
        '(not false) and (not true)' => false,
        '(not false) and (not false)' => true,

        'and not(false) not(true)' => false,   # /!\
        'and not(false) not(false)' => false,  #

      }.test_each(self)
    end
  end
end

