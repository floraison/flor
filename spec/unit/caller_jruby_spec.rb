
#
# specifying flor
#
# Sun Aug 11 21:48:34 JST 2019
#

require 'spec_helper'


describe 'Flor::Caller (JRuby)', if: RUBY_PLATFORM.match(/java/) do

  before :all do

    @caller = Flor::Caller.new(nil)
  end

  describe '#split_cmd (protected)' do

    {

      'python lib/for_caller.py' =>
        %w[ python lib/for_caller.py ],
      'python lib/for_caller.py "hello world"' =>
        [ 'python', 'lib/for_caller.py', 'hello world' ],
      "python lib/for_caller.py 'hello world'" =>
        [ 'python', 'lib/for_caller.py', 'hello world' ],
      'python x.py "hello \'enchanted\' world"' =>
        [ 'python', 'x.py', "hello 'enchanted' world" ],

    }.each do |cmd, a|

      it "splits #{cmd.inspect}" do

        expect(@caller.send(:split_cmd, cmd)).to eq(a)
      end
    end
  end
end

