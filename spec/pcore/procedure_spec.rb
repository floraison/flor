
#
# specifying flor
#
# Tue Jan 10 10:57:43 JST 2017
#

require 'spec_helper'


describe Flor::Procedure do

  before :each do

# TODO automate this "context building"
#      why not use the TransientExecutor to build normally everything
#      until a certain point is reached, then return the expected message
#      and stop (instead of executing said message).
#      would be a kind of special "wait"
#
#      Now, how about doing that for unit/ ?
#      And how about "concurrence", two messages expected?
#
#      For core/ could I use a StoppedExecutor < TransientExecutor.new ?

    @executor = Flor::TransientExecutor.new

    @m0 = {
      'nid' => '0', 'payload' => {},
      'tree' => [ 'sequence', [ [ 'sequence', [], 2 ] ], 1 ] }
    @m01 = {
      'nid' => '0_0', 'from' => '0', 'payload' => {},
      'tree' => [ 'sequence', [], 2 ] }

    @n0 = @executor.send(:make_node, @m0)
    @n0['tree'] = @m0['tree']
    @n0['cnodes'] = [ '0_0' ]

    @n01 = @executor.send(:make_node, @m01)

    @p0 = Flor::Pro::Sequence.new(@executor, @n0, @m0)
    @p01 = Flor::Pro::Sequence.new(@executor, @n01, @m01)

    [ @p0, @p01 ].each do |pr|
      class << pr; public :execute; end
    end
  end

  describe '#execute' do

    it 'responds immediately if it has no children' do

      ms = @p01.execute

      expect(ms.size).to eq(1)

      m = ms.first

      expect(
        m.select { |k, v| %w[ point nid from ].include?(k) }
      ).to eq(
        { 'point' => 'receive', 'nid' => '0', 'from' => '0_0' }
      )
    end

    it 'responds immediately if it has no children' do

      flon = %{
        sequence
          sequence
      }

      ms = @executor.launch(flon, until: '0_0 execute')

      expect(to_s(ms.first)).to eq('(msg 0_0 execute from:0)')

      #ms = @executor.step # TODO
    end
  end

  describe '#receive' do
  end
  describe '#cancel' do
  end
end

