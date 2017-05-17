
#
# specifying flor
#
# Wed May 17 13:07:53 JST 2017  Basset Café
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  # ```clojure
  # (doseq [n (range 1 101)]
  #   (println
  #     (match [(mod n 3) (mod n 5)]
  #       [0 0] "FizzBuzz"
  #       [0 _] "Fizz"
  #       [_ 0] "Buzz"
  #       :else n)))
  # ```

  describe 'match' do

    it "doesn't mind being called without arguments"

    it 'overlaps "case"' do

      r = @executor.launch(
        %q{
          set a 1
          match a
            0; "zero"
            1; "one"
            2; "two"
            #else; "more than two"
        })

      expect(r['point']).to eq('terminated')
      expect(r['payload']['ret']).to eq('one')
    end

    context 'guards' do

      it 'accepts guards'
    end
  end
end

