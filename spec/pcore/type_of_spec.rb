
#
# specifying flor
#
# Sun Sep 30 10:28:28 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'type-of, type' do

    {

      'type 0' => :number,
      'type-of 0' => :number,
      'type-of 0.1' => :number,
      'type-of "hell"' => :string,
      'type-of []' => :array,
      'type-of {}' => :object,
      'type-of { a: 1 }' => :object,
      'type-of true' => :boolean,
      'type-of false' => :boolean,
      'type-of null' => :null,

      '0; type _' => :number,
      '"alpha"; type _' => :string,
      "'alpha'; type-of _" => :string,

      'type-of null tag: "check"' => :null,
      'null; type-of tag: "check"' => :null,

    }.each do |k, v|

      it "yields '#{v}' for `#{k}`" do

        r = @executor.launch(k)

        expect(r['point']).to eq('terminated')
        expect(r['payload']['ret']).to eq(v.to_s)
      end
    end
  end
end

