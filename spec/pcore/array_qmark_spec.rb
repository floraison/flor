
#
# specifying flor
#
# Sat Sep 29 23:16:53 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'array?, object?, boolean?, number?, ...' do

    {

      'array? []' => true,
      '[]; array? _' => true,
      'array? false' => false,
      'false; array? _' => false,

      'object? {}' => true,
      'object? false' => false,

      'number? 0' => true,
      'number? 0.1' => true,
      'number? "dang"' => false,
      'number? []' => false,

      'string? "hello"' => true,
      'string? []' => false,

      'true? true' => true,
      'true? false' => false,
      'true? 0' => false,

      'boolean? true' => true,
      'boolean? false' => true,
      'boolean? []' => false,

      'null? null' => true,
      'null? 0' => false,

      'false? false' => true,
      'false? true' => false,
      'false? "false"' => false,

      'nil? null' => true,
      'nil? 0' => false,

      'pair? [ 0 1 ]' => true,
      'pair? []' => false,
      'pair? 0' => false,

      'float? 1.0' => true,
      'float? 1' => false,
      'float? {}' => false,

    }.each do |k, v|

      it "yields #{v ? 'true ' : 'false'} for #{k.inspect}" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v)
      end
    end
  end
end

