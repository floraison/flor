
module Flor

  COLS = Hash[*%w[

    reset 0;0
    bright 1 dim 2 underlined 4 blink 5 reverse 7 hidden 8 default 39
    black 30 red 31 green 32 yellow 33 blue 34 magenta 35 cyan 36
    light_gray 37 dark_gray 90 light_red 91 light_green 92
    light_yellow 93 light_blue 94 light_magenta 95 light_cyan 96 white 97
    bg_default 49 bg_black 40 bg_red 41 bg_green 42 bg_yellow 43 bg_blue 44
    bg_magenta 45 bg_cyan 46 bg_light_gray 47 bg_dark_gray 100
    bg_light_red 101 bg_light_green 102 bg_light_yellow 103
    bg_light_blue 104 bg_light_magenta 105 bg_light_cyan 106
    bg_white 107

    brown yellow purple magenta dark_grey dark_gray light_grey light_gray

    rd red bl blue bu blue ba black bk black gn green gr green dg dark_gray
    gy light_gray lg light_gray yl yellow y yellow ma magenta rs reset
    br bright bri bright un underlined rv reverse bn blink blg bg_light_gray
    und underlined rev reverse
  ]]

  class Colours

    Flor::COLS.each do |k, v|
      if v.match(/\A\d/)
        class_eval(%{
          def #{k}(s=nil)
           s ? "[#{v}m" + s + "[0;9m": "[#{v}m"
           end })
      else
        class_eval(
          "alias #{k} #{v}")
      end
    end
  end

  class NoColours

    Flor::COLS.each do |k, v|
      if v.match(/\A\d/)
        class_eval("def #{k}(s=''); s; end")
      else
        class_eval("alias #{k} #{v}")
      end
    end
  end

  @colours = Colours.new
  @no_colours = NoColours.new

  def self.no_colours

    @no_colours
  end

  def self.colours(opts={})

    #opts =
    #  case opts
    #  when Hash then opts
    #  when Colours, NoColours then { color: opts }
    #  else { out: opts }
    #  end

    c = nil;
      [ :color, :colour, :colors, :colours ].each do |k|
        if opts.has_key?(k); c = opts[k]; break; end
      end

    return @colours if c == true
    return @no_colours if c == false

    o = opts[:out] || $stdout

    return @colours if (
      (o.respond_to?(:log_colours?) ? o.log_colours? : o.tty?) ||
      ($0[-6..-1] == '/rspec' &&
        (ARGV.include?('--tty') || ARGV.include?('--color'))))

    @no_colours
  end

  def self.decolour(s)

    s.gsub(/\x1b\[\d+(;\d+)?m/, '')
  end

  def self.no_colour_length(s)

    decolour(s).length
  end

  def self.truncate_string(s, maxlen, post='...')

    ncl = no_colour_length(s)
    r = StringIO.new
    l = 0

    s.scan(/(\x1b\[\d+(?:;\d+)?m|[^\x1b]+)/) do |ss, _|
      if ss[0, 1] == ""
        r << ss
      else
#p({ r: r.string, l: l, ssl: ss.length, maxlen: maxlen, reml: maxlen - l })
        ss = ss[0, maxlen - l]
        r << ss
        l += ss.length
        break if l >= maxlen
      end
    end

    return r.string if l < maxlen

    if post.is_a?(String)
      r << post
    elsif post.is_a?(Proc)
      r << post.call(ncl, maxlen, s)
    end

    r.string
  end

  class << self

    alias decolor decolour

    alias bw_length no_colour_length
    alias nocolor_length no_colour_length
    alias no_color_length no_colour_length
    alias nocolour_length no_colour_length
  end
end

