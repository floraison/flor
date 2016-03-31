
#
# specifying flor
#
# Thu Mar  3 17:57:03 JST 2016
#

require 'spec_helper'


class Flor::Executor

  public :rewrite
end


describe Flor::Executor do

  describe '#rewrite' do

    context 'when no rewrite' do

      it 'returns the tree as is' do

        t0 =
          Flor::Rad.parse(%{
            sequence
              a
              b
          })

        t1 = Flor::Executor.new({}).rewrite(t0)

        expect(t1).to eq(t0)
      end
    end

    context "when 'if' suffix" do

      it 'wraps the suffixed line in an ife'
    end

    context "when 'unless' suffix" do

      it 'wraps the suffixed line in an unlesse'
    end

    context 'during execution' do

      it "sets node['tree'] when there is a rewrite"
      it "does not set node['tree'] when there is no rewrite"
    end
  end
end

