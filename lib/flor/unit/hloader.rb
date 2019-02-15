
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

    ENV_CATS = %w[ variables libraries taskers hooks ]

    def add(cat, path, value)

      c = cat.to_s

      fail ArgumentError.new("unknown category #{c.inspect}") \
        unless ENV_CATS.include?(c)

      e = (@environment[c] ||= [])
      e << [ *split(path), value ]
      e.sort_by! { |pa, _, _| pa.count('.') }
    end

    def remove(cat, path)

      c = cat.to_s

      fail ArgumentError.new("unknown category #{c.inspect}") \
        unless ENV_CATS.include?(c)

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

      entries('libraries', domain)
        .each { |pa, ke, va|
          next unless pa == path && ke == key
          return [ [ pa, ke ].join('.'), va ] }

      nil

#      domain, name, opts = [ domain, nil, name ] if name.is_a?(Hash)
#      domain, name = split_dn(domain, name)
#
#      if m = name.match(/(\.flor?)\z/)
#        name = name[0..m[1].length - 1]
#      end
#
#      path, _, _ = (Dir[File.join(@root, '**/*.{flo,flor}')])
#        .select { |f| f.index('/lib/') }
#        .collect { |pa| [ pa, *expose_dn(pa, opts) ] }
#        .select { |pa, d, n| n == name && is_subdomain?(domain, d) }
#        .sort_by { |pa, d, n| d.count('.') }
#        .last
#
#      path ? [ Flor.relativize_path(path), File.read(path) ] : nil
    end

    def tasker(domain, name, message={})

#      # NB: do not relativize path, because Ruby load path != cwd,
#      # stay absolute for `require` and `load`
#
#      domain, name = split_dn(domain, name)
#
#      pat, _, nam = Dir[File.join(@root, '**/*.json')]
#        .select { |pa| pa.index('/lib/taskers/') }
#        .collect { |pa| [ pa, *expose_dn(pa, {}) ] }
#        .select { |pa, d, n|
#          is_subdomain?(domain, [ d, n ].join('.')) ||
#          (n == name && is_subdomain?(domain, d)) }
#        .sort_by { |pa, d, n| d.count('.') }
#        .last
#
#      return nil unless pat
#
#      conf = eval(pat, message)
#
#      return conf if nam == name
#
#      conf = conf[name]
#
#      return nil unless conf
#
#      (conf.is_a?(Array) ? conf : [ conf ])
#        .each { |h| h['_path'] = pat }
#
#      conf
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

    def split(path, key=nil)

      return [ path, key ] if key

      i = path.rindex('.') || 0

      [ path[0, i], path[(i == 0 ? i : i + 1)..-1] ]
    end

    def entries(cat, domain)

      (@environment[cat.to_s] || {})
        .select { |path, _, _| Flor.sub_domain?(path, domain) }
    end
  end
end

