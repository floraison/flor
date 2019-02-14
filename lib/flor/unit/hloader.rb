
module Flor

  # A loader which keeps everything in a Hash, while the traditional/default
  # Flor::Loader reads from a file tree.
  #
  class HashLoader

    # NB: tasker configuration entries start with "loa_", like for Flor::Loader

    attr_reader :environment

    def environment=(h)

      @environment = Flor.to_string_keyed_hash(h)
    end

    def initialize(unit)

      @unit = unit

      self.environment = (@unit.conf['lod_environment'] || {})
    end

    def shutdown
    end

    def variables(domain)

      deflate(@environment['variables'] || {})
        .select { |pa, _, _| is_subdomain?(domain, pa) }
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

    def deflate(h)

      do_deflate(h, {}, nil)
        .sort_by { |k, _|
          k.count('.') }
        .collect { |k, v|
          i = k.rindex('.') || 0
          [ k[0, i], k[(i == 0 ? i : i + 1)..-1], v ] }
    end

    def do_deflate(h, out, path)

      h
        .inject(out) { |r, (k, v)|
          pathk = path ? [ path, k ].join('.') : k
          if v.is_a?(Hash)
            do_deflate(v, r, pathk)
          else
            r[pathk] = v
          end
          r }
    end

# TODO move to upstream class...
#
    # is da a subdomain of db?
    #
    def is_subdomain?(da, db)

      da == db ||
      db == '' ||
      da[0, db.length + 1] == db + '.'
    end

#    def split_dn(domain, name)
#
#      if name
#        [ domain, name ]
#      else
#        elts = domain.split('.')
#        [ elts[0..-2].join('.'), elts[-1] ]
#      end
#    end
#
#    def expose_d(path, opts)
#
#      pa = path[@root.length..-1]
#      pa = pa[5..-1] if pa[0, 5] == '/usr/'
#
#      libregex =
#        opts[:subflows] ?
#        /\/lib\/(subflows|flows|hooks|taskers)\// :
#        /\/lib\/(flows|hooks|taskers)\//
#
#      pa
#        .sub(/\/etc\/variables\//, '/')
#        .sub(libregex, '/')
#        .sub(/\/\z/, '')
#        .sub(/\/(flo|flor|dot|hooks)\.json\z/, '')
#        .sub(/\.(flo|flor|json)\z/, '')
#        .sub(/\A\//, '')
#        .gsub(/\//, '.')
#    end
#
#    def expose_dn(path, opts)
#
#      pa = expose_d(path, opts)
#
#      if ri = pa.rindex('.')
#        [ pa[0..ri - 1], pa[ri + 1..-1] ]
#      else
#        [ '', pa ]
#      end
#    end
#
#    def eval(path, context)
#
#      src =
#        @mutex.synchronize do
#
#          mt1 = File.mtime(path)
#          val, mt0 = @cache[path]
#
#          if val && mt1 == mt0
#            val
#          else
#            (@cache[path] = [ Flor::ConfExecutor.load(path), mt1 ]).first
#          end
#        end
#
#      Flor::ConfExecutor.interpret(path, src, context)
#    end
  end
end

