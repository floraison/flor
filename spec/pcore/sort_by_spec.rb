
#
# specifying flor
#
# Sat Nov 24 15:35:37 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'sort_by' do

    it 'maps and sorts' do

      r = @executor.launch(
        %q{
          sort_by [ { n: 1 } { n: 0 } { n: 4 } { n: 3 } ]
            def e
              e.n
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 3 }, { 'n' => 4 } ])
    end

    it 'maps and sorts (coll then fun)' do

      r = @executor.launch(
        %q{
          sort_by [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ] (def e \ e.n)
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ])
    end

    it 'maps and sorts (fun then coll)' do

      r = @executor.launch(
        %q{
          sort_by (def e \ e.n) [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ]
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ])
    end

    it 'maps and sorts (incoming collection)' do

      r = @executor.launch(
        %q{
          [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ]
          sort_by (def e \ e.n)
        })

      expect(r['point']).to eq('terminated')

      expect(r['payload']['ret']).to eq([
       { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ])
    end
  end
end

