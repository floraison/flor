#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module Flor

  class Colours

    def reset; "[0;0m"; end

    def bright;      "[1m"; end
    def dim;         "[2m"; end
    def underlined;  "[4m"; end
    def blink;       "[5m"; end
    def reverse;     "[7m"; end
    def hidden;      "[8m"; end

    def default;        "[39m"; end
    def black;          "[30m"; end
    def red;            "[31m"; end
    def green;          "[32m"; end
    def yellow;         "[33m"; end
    def blue;           "[34m"; end
    def magenta;        "[35m"; end
    def cyan;           "[36m"; end
    def light_gray;     "[37m"; end

    def dark_gray;      "[90m"; end
    def light_red;      "[91m"; end
    def light_green;    "[92m"; end
    def light_yellow;   "[93m"; end
    def light_blue;     "[94m"; end
    def light_magenta;  "[95m"; end
    def light_cyan;     "[96m"; end
    def white;          "[97m"; end

    def bg_default;        "[49m"; end
    def bg_black;          "[40m"; end
    def bg_red;            "[41m"; end
    def bg_green;          "[42m"; end
    def bg_yellow;         "[43m"; end
    def bg_blue;           "[44m"; end
    def bg_magenta;        "[45m"; end
    def bg_cyan;           "[46m"; end
    def bg_light_gray;     "[47m"; end

    def bg_dark_gray;      "[100m"; end
    def bg_light_red;      "[101m"; end
    def bg_light_green;    "[102m"; end
    def bg_light_yellow;   "[103m"; end
    def bg_light_blue;     "[104m"; end
    def bg_light_magenta;  "[105m"; end
    def bg_light_cyan;     "[106m"; end
    def bg_white;          "[107m"; end

    alias brown yellow
    alias purple magenta
    alias dark_grey dark_gray
    alias light_grey light_gray

    alias rd red
    alias bl blue
    alias bu blue
    alias ba black
    alias bk black
    alias gn green
    alias gr green
    alias dg dark_gray
    alias gy light_gray
    alias lg light_gray
    alias yl yellow
    alias ma magenta

    alias rs reset
    alias br bright
    alias un underlined
    alias rv reverse
    alias bn blink

    alias blg bg_light_gray
    alias bri bright
    alias und underlined
    alias rev reverse
  end

  class NoColours < Colours

    %w[
      reset
      bright dim underlined blink reverse hidden
      default black red green yellow blue magenta cyan light_gray
      dark_gray light_red light_green light_yellow light_blue light_magenta
      light_cyan white
      bg_default bg_black bg_red bg_green bg_yellow bg_blue bg_magenta bg_cyan
      bg_light_gray
      bg_dark_gray bg_light_red bg_light_green bg_light_yellow bg_light_blue
      bg_light_magenta bg_light_cyan bg_white
    ].each { |m| define_method(m) { '' } }
  end

  @colours = Colours.new
  @no_colours = NoColours.new

  def self.no_colours

    @no_colours
  end

  def self.colours(opts={})

    return @no_colours unless $stdout.tty?

    opts[:colour] = true unless opts.has_key?(:color) || opts.has_key?(:colour)

    return @colours if opts[:color] || opts[:colour]
    @no_colours
  end
end

