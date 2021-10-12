# frozen_string_literal: true

# flotojson.rb

require 'flor'

FLAGS_WITH_VALUE = []

flags = {}
files = []

if (ARGV & [ '-h', '--help']).any?
  puts
  puts "bin/flotojson [flags] filename"
  puts
  puts "  turns a flor .flo process definition to its tree representation"
  puts
  puts "  flags:"
  puts "    --pp   pretty prints instead of dumping as JSON"
  puts
  exit 0
end

args = ARGV.dup

loop do

  a = args.shift; break unless a

  if a.size > 1 && a[0, 1] == '-'
    flags[a] = FLAGS_WITH_VALUE.include?(a) ? a.shift : true
  else
    files << a
  end
end

#STDERR.puts flags.inspect
#STDERR.puts files.inspect

#    t =
#      tree.is_a?(String) ?
#      Flor.parse(tree, opts[:fname] || opts[:path], opts) :
#      tree
#
#    unless t
#
#      #h = opts.merge(prune: false, rewrite: false, debug: 0)
#      #Raabro.pp(Flor.parse(tree, h[:fname], h))
#        # TODO re-parse and indicate what went wrong...
#
#      fail ArgumentError.new(
#        "flow parsing failed: " + tree.inspect[0, 35] + '...')
#    end

fname = files.first
content = File.read(fname)
tree = Flor.parse(content, fname, {})

if flags['--pp']
  pp tree
else
  puts JSON.dump(tree)
end

