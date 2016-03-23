
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

#    context '():' do
#
#      it 'rewrites  task bob count: (+ 1 2)' do
#
#        t0 =
#          Flor::Rad.parse(%{
#            task bob count: (+ 1 2)
#          }, 'sx')
#
#        t1 = Flor::Executor.new({}).rewrite(t0)
#
#        expect(t1).to eqt(
#          [ 'sequence', {}, 2, [
#            [ 'set', { '_0' => 'w._0' }, 2, [
#              [ '+', { '_0' => 1, '_1' => 2 }, 2, [] ]
#            ] ],
#            [ 'task', { '_0' => 'bob', 'count' => '$(w._0)' }, 2, [] ]
#          ], 'sx' ]
#        )
#      end
#    end
  end
end

