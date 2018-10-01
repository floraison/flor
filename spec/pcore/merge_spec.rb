
#
# specifying flor
#
# Mon Oct  1 07:24:41 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'merge' do

    {

      "merge { a: 0 b: 1 } { b: 'B' c: 'C' }" =>
        { 'a' => 0, 'b' => 'B', 'c' => 'C' },
      "merge { b: 'B' c: 'C' } { a: 0 b: 1 }" =>
        { 'a' => 0, 'b' => 1, 'c' => 'C' },
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 }" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },
      "merge { a: 0 } { b: 1 } { c: 2 }" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },
      "merge { a: 0 } { b: 1 } 'nada' { c: 2 } tags: 'xxx'" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },

      "{ a: 0 }; merge { b: 1 } { c: 2 }" =>
        { 'a' => 0, 'b' => 1, 'c' => 2 },

    }.each do |k, v|

      it "succeeds for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end

    it 'fails if it cannot merge'
  end
end

