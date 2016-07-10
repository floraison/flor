
#
# specifying flor
#
# Sun Jul 10 06:48:32 JST 2016
#

require 'spec_helper'


describe 'Flor core' do

  describe Flor::Procedure do

    describe '.first_name' do

      it 'returns the first name for a procedure' do

        expect(Flor::Procedure.first_name('_num')).to eq('_atom')
        expect(Flor::Procedure.first_name('_unlesse')).to eq('_ife')
        expect(Flor::Procedure.first_name('begin')).to eq('sequence')
      end
    end
  end
end

