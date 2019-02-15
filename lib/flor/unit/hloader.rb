
module Flor

  # A loader which keeps everything in a Hash, while the traditional/default
  # Flor::Loader reads from a file tree.
  #
  class HashLoader

    # NB: tasker configuration entries start with "loa_", like for Flor::Loader

    attr_reader :environment

    def environment=(h)

      @environment = Flor.to_string_keyed_hash(h)
        .inject({}) { |r, (cat, v)|
          r[cat] = recompose(v)
          r }
    end

    def initialize(unit)

      @unit = unit

      self.environment = (@unit.conf['lod_environment'] || {})
    end

    def shutdown
    end

    HCATS = {
      'variable' => 'variables',
      'library' => 'libraries',
      'tasker' => 'taskers',
      'hook' => 'hooks' }
    CATS =
      HCATS.values

    def add(cat, path, value)

      c = recat(cat)

      value = Flor.to_string_keyed_hash(value) if c == 'taskers'

      e = (@environment[c] ||= [])
      e << [ *split(path), value ]
      e.sort_by! { |pa, _, _| pa.count('.') }
    end

    def remove(cat, path)

      c = recat(cat)

      e = @environment[c]
      return [] unless e

      pa, ke = split(path)

      e.reject! { |epa, eke, _| epa == pa && eke == ke }
    end

    def variables(domain)

      entries('variables', domain)
        .inject({}) { |h, (_, k, v)| h[k] = v; h }
    end

    #def procedures(path)
    #
    #  # TODO
    #  # TODO work with Flor.load_procedures
    #end

    # If found, returns [ source_path, path ]
    #
    def library(domain, name=nil, opts={})

      path, key = split(domain, name)

      entries('libraries', path)
        .each { |pa, ke, va|
          next unless pa == path && ke == key
          return [ [ pa, ke ].join('.'), va ] }

      nil
    end

    def tasker(domain, name, message={})

      path, key = split(domain, name)

      entries('taskers', path)
        .reverse # FIXME
        .each { |pa, ke, va|
          return tasker_conf(pa, va, message) if ke == key }

      nil
    end

    def hooks(domain, name=nil)

#      # NB: do not relativize path, because Ruby load path != cwd,
#      # stay absolute for `require` and `load`
#
#      Dir[File.join(@root, '**/*.json')]
#        .select { |f| f.index('/lib/hooks/') }
#        .collect { |pa| [ pa, expose_d(pa, {}) ] }
#        .select { |pa, d| is_subdomain?(domain, d) }
#        .sort_by { |pa, d| d.count('.') }
#        .collect { |pa, d|
#          eval(pa, {}).each_with_index { |h, i|
#            h['_path'] = pa + ":#{i}" } }
#        .flatten(1)
    end

    def load_hooks(exid)

#      hooks(Flor.domain(exid))
#        .collect { |h| Flor::Hook.new(@unit, exid, h) }
    end

    protected

    def recompose(h)

      deflate(h, {}, nil)
        .sort_by { |k, _| k.count('.') }
        .collect { |k, v| [ *split(k), v ] }
    end

    def deflate(h, out, path)

      h
        .inject(out) { |r, (k, v)|
          pathk = path ? [ path, k ].join('.') : k
          if v.is_a?(Hash)
            deflate(v, r, pathk)
          else
            r[pathk] = v
          end
          r }
    end

    def recat(cat)

      c = cat.to_s
      c = HCATS[c] || c

      fail ArgumentError.new("unknown category #{cat.to_s.inspect}") \
        unless CATS.include?(c)

      c
    end

    def split(path, key=nil)

      return [ path, key ] if key

      i = path.rindex('.') || 0

      [ path[0, i], path[(i == 0 ? i : i + 1)..-1] ]
    end

    def entries(cat, domain)

      (@environment[cat.to_s] || {})
        .select { |path, _, _| Flor.sub_domain?(path, domain) }
    end

    def tasker_conf(path, value, message)

      is_array = value.is_a?(Array)

      a = (is_array ? value : [ value ])
        .collect { |v|
          h = v.is_a?(String) ? eval(path, v, message) : v
          h['_path'] = path
          h['root'] = nil
          h }

      is_array ? a : a.first
    end

    def eval(path, code, context)

      code = Flor::ConfExecutor.load(code)

      Flor::ConfExecutor.interpret(path, code, context)
    end
  end
end

