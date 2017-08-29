
require 'pp'

PURI = 'https://github.com/floraison/flor/tree/master/'


def make_proc_doc(path)

  lines = File.readlines(path)

  cline = lines
    .index { |l| l.match(/^class Flor::Pro::.* < Flor::(Pro|Macro)/) }

  return unless cline && cline > 0

  nline = lines.index { |l| l.match(/^ +names?/) }
  return unless nline

  names = lines[nline][7..-1]
  names = "[ #{names} ]" if names.index(',')
  names = Array(eval(names))
  #names = names.select { |n| n[0, 1] != '_' }

  return if names.empty?

  fname = File.basename(path, '.rb')

  lines = lines[cline..nline].select { |l| l.match(/^  #/) }

  return if lines.empty?

  lines = lines.collect { |l| l.strip.length == 1 ? "\n" : l[4..-1] }
  #
  lines.unshift("\n") if lines.first.strip != ''
  lines.push("\n") if lines.last.strip != ''

  slines = lines[1..-1].take_while { |l| l.strip != '' }
  summary = slines.collect(&:strip).join(' ')

  File.open("doc/procedures/#{fname}.md", 'wb') do |f|

    f.print("\n# #{names.join(', ')}\n")
    lines.each { |l| f.print(l) }

    cat =
      path.match(/\/pcore\//) ? 'pcore' : 'punit'
    spec_paths =
      names.inject([]) { |a, name|
        spa = "spec/#{cat}/#{name}_spec.rb"
        a << [ name, spa ] if File.exist?(spa)
        a
      }

    f.puts("\n* [source](#{File.join(PURI, path)})")
    spec_paths.each do |name, spath|
      f.puts("* [#{name} spec](#{File.join(PURI, spath)})")
    end
    f.puts
  end

  [ File.basename(File.dirname(path))[1..-1], names, "#{fname}.md", summary ]
end

def make_procedures_doc

  procs =
    (
      Dir["lib/flor/pcore/*.rb"].sort + Dir["lib/flor/punit/*.rb"].sort
    ).collect { |path| make_proc_doc(path) }.compact
  pp procs

  File.open('doc/procedures/readme.md', 'wb') do |f|

    f.puts
    f.puts '# procedures'
    f.puts
    f.puts '## core'
    f.puts
    procs.each do |flavour, names, fname, summary|
      f.puts(
        "* [#{names.join(', ')}](#{fname}) - #{summary}"
      ) if flavour == 'core'
    end
    f.puts
    f.puts '## unit'
    f.puts
    procs.each do |flavour, names, fname, summary|
      f.puts(
        "* [#{names.join(', ')}](#{fname}) - #{summary}"
      ) if flavour == 'unit'
    end
    f.puts
  end
end

