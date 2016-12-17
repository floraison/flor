
require 'pp'


def make_proc_doc(path)

  lines = File.readlines(path)
#class Flor::Pro::Break < Flor::Procedure

  cline = lines.index { |l| l.match(/^class Flor::Pro::.* < Flor::Procedure$/) }

  return unless cline > 0

  nline = lines.index { |l| l.match(/^ +names?/) }

  names = lines[nline][7..-1]
  names = "[#{names}]" if names.index(',')
  names = Array(eval(names))
  names = names.select { |n| n[0, 1] != '_' }

  return if names.empty?

  fname = File.basename(path, '.rb')

  lines = lines[cline..nline].select { |l| l.match(/^  # /) }

  return if lines.empty?

  p [ fname, names ]

  File.open("doc/procedures/#{fname}.md", 'wb') do |f|

    #f.print("\n# #{fname}\n")
    f.print("\n# #{names.join(', ')}\n\n")
    lines.each { |l| f.print(l[4..-1]) }
    f.puts
  end
end

def make_procedures_doc(flavour)

  Dir["lib/flor/p#{flavour}/*.rb"].each do |path|
    make_proc_doc(path)
  end
end

