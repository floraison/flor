
#
# specifying flor
#
# Sat Sep 29 23:16:53 JST 2018
#

require 'spec_helper'


describe 'Flor procedures' do

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

      'boolean? true tag: "xxx"' => true,
      'true; boolean? tag: "xxx"' => true,
      'string? {} tag: "xxx"' => false,
      '{}; string? tag: "xxx"' => false,

    }.test_each(self)
  end
end

