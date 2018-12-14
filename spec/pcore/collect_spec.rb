
#
# specifying flor
#
# Wed Nov  1 06:29:39 JST 2017
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'collect' do

    it 'maps elements' do

      r = @executor.launch(
        %q{
          collect [ 1, 2, 3 ]
            + elt 3
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 4, 5, 6 ])
    end

    it 'maps f.ret by default' do

      r = @executor.launch(
        %q{
          [ 1, 2, 3 ]
          collect
            + elt 2
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 3, 4, 5 ])
    end

    it 'maps to a function by its name' do

      r = @executor.launch(
        %q{
          define add3 x
            + x 3
          collect [ 0, 1 ] add3
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 3, 4 ])
    end

    it 'does not let att get in the way of col and fun' do

      r = @executor.launch(
        %q{
          collect [ 0, 1, 2 ], tag: 'y'
            + elt 3
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ 3, 4, 5 ])
    end

    it 'shows the index via the "idx" var' do

      r = @executor.launch(
        %q{
          collect [ 'a', 'b' ]
            [ idx, elt ]
        })

      expect(r).to have_terminated_as_point
      expect(r['payload']['ret']).to eq([ [ 0, 'a' ], [ 1, 'b' ] ])
    end

    context 'with objects' do

      it 'maps object with (key, val)' do

        r = @executor.launch(
          %q{
            collect { a: 'A', b: 'B', c: 'C' }
              [ key val ]
          })

        expect(r).to have_terminated_as_point

        expect(r['payload']['ret']
          ).to eq([ [ 'a', 'A' ], [ 'b', 'B' ], [ 'c', 'C' ] ])
      end

      it 'maps object with (key, val, idx)' do

        r = @executor.launch(
          %q{
            collect { a: 'A', b: 'B', c: 'C' }
              [ idx key val ]
          })

        expect(r).to have_terminated_as_point

        expect(r['payload']['ret']
          ).to eq([ [ 0, 'a', 'A' ], [ 1, 'b', 'B' ], [ 2, 'c', 'C' ] ])
      end

      it 'collects' do

        r = @executor.launch(
          %q{
            set users [
              { name: 'Alfred' mail: 'al@yahoo.com' }
              { name: 'Boris' mail: 'bo@hotmail.com' }
              { name: 'Carla' mail: 'cara@gmail.com' } ]
            # ...
            collect users \ elt.mail
          })

        expect(r).to have_terminated_as_point

        expect(r['payload']['ret']
          ).to eq(%w[ al@yahoo.com bo@hotmail.com cara@gmail.com ])
      end
    end
  end
end

