
require 'pp'

PURI =
  'https://github.com/floraison/flor/tree/master/'

def determine_names(path)

  lines = File.readlines(path)

  cline = lines.index { |l| l =~ /^class Flor::Pro::.* < Flor::(Pro|Macro)/ }
  return nil unless cline && cline > 0

  nline = lines.index { |l| l.match(/^ +names?/) }
  return nil unless nline

  nl = nline
  names = lines[nl][7..-1]
  names = "[ #{names} ]" if names.index(',')
  while ! names.index(']')
    nl = nl + 1
    names = names + "\n" + (lines[nl][3..-1] || '')
  end if names.index('[')
  names = Array(eval(names))
  #names = names.select { |n| n[0, 1] != '_' }
  return nil if names.empty?

  lines = lines[cline..nline].select { |l| l.match(/^  #/) }
  return nil if lines.empty?

  lines = lines.collect { |l| l.strip.length == 1 ? "\n" : l[4..-1] }

  [ names, lines ]
end

NAMES_AND_LINES = Dir['lib/flor/{pcore,punit}/*.rb']
  .sort
  .inject({}) { |h, path|
    names = determine_names(path)
    h[path] = names if names
    h }
NAMES_AND_FILES = NAMES_AND_LINES
  .inject({}) { |h, (k, v)|
    v[0].each { |n| h[n] = File.basename(k, '.rb') + '.md' }
    h }
NAMES = NAMES_AND_LINES
  .values
  .collect(&:first)
  .flatten
ALSO_NAMES =
  NAMES - %w[ and or ]

def make_proc_doc(path, names_and_lines)

  names, lines = names_and_lines

  fname = File.basename(path, '.rb')

  if see_also = lines.index("## see also\n")

    see_also = see_also + 2
    count = lines[see_also..-1].index("\n") || 0

    (see_also..see_also + count).each do |i|
      lines[i] = lines[i]
        .gsub(/\w+\??/) { |w|
          dw = w.downcase
          fw = NAMES_AND_FILES[dw]
          ALSO_NAMES.include?(dw) ? "[#{w}](#{fw})" : w }
    end
    #pp lines
  end

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

  procs = NAMES_AND_LINES
    .collect { |path, nsls| make_proc_doc(path, nsls) }
    .compact
  #pp procs

  File.open('doc/procedures/README.md', 'wb') do |f|

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
    f.puts
    f.puts "## core and unit tree"
    f.puts
    f.puts `make doct`
    f.puts
  end
end

