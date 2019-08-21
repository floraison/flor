
module Flor

  class Loader

    # NB: tasker configuration entries start with "loa_"

    def initialize(unit)

      @unit = unit

      @cache = {}
      @mutex = Mutex.new

      @root = File.absolute_path(
        @unit.conf['lod_path'] || @unit.conf['root'] || '.')
    end

    def shutdown
    end

    def variables(domain)

      Dir[File.join(@root, '**/*.json')]
        .select { |f| f.index('/etc/variables/') }
        .collect { |pa| [ pa, expose_d(pa, {}) ] }
        .select { |pa, d| Flor.sub_domain?(d, domain) }
        .sort_by { |pa, d| d.count('.') }
        .inject({}) { |vars, (pa, _)| vars.merge!(eval(pa, {})) }
    end

    #def procedures(path)
    #
    #  # TODO
    #  # TODO work with Flor.load_procedures
    #end

    # If found, returns [ source_path, path ]
    #
    def library(domain, name=nil, opts={})

      domain, name, opts = [ domain, nil, name ] if name.is_a?(Hash)
      domain, name = split_dn(domain, name)

      if m = name.match(/(\.flor?)\z/)
        name = name[0..m[1].length - 1]
      end

      path, _, _ = (Dir[File.join(@root, '**/*.{flo,flor}')])
        .select { |f| f.index('/lib/') }
        .collect { |pa| [ pa, *expose_dn(pa, opts) ] }
        .select { |pa, d, n| n == name && Flor.sub_domain?(d, domain) }
        .sort_by { |pa, d, n| d.count('.') }
        .last

      path ? [ Flor.relativize_path(path), File.read(path) ] : nil
    end

    def tasker(domain, name, message={})

      # NB: do not relativize path, because Ruby load path != cwd,
      # stay absolute for `require` and `load`

      domain, name = split_dn(domain, name)

      pat, _, nam = Dir[File.join(@root, '**/*.{json,rb}')]
        .select { |pa| pa.index('/lib/taskers/') }
        .collect { |pa| [ pa, *expose_dn(pa, {}) ] }
        .select { |pa, d, n|
          Flor.sub_domain?([ d, n ].join('.'), domain) ||
          (n == name && Flor.sub_domain?(d, domain)) }
        .sort_by { |pa, d, n| d.count('.') }
        .last

      return nil unless pat

      conf = eval(pat, message)

      return conf if nam == name

      conf = conf[name]

      return nil unless conf

      (conf.is_a?(Array) ? conf : [ conf ])
        .each { |h| h['_path'] = pat }

      conf
    end

    def hooks(domain)

      # NB: do not relativize path, because Ruby load path != cwd,
      # stay absolute for `require` and `load`

      Dir[File.join(@root, '**/*.json')]
        .select { |f| f.index('/lib/hooks/') }
        .collect { |pa| [ pa, expose_d(pa, {}) ] }
        .select { |pa, d| Flor.sub_domain?(d, domain) }
        .sort_by { |pa, d| d.count('.') }
        .collect { |pa, d|
          eval(pa, {})
            .each_with_index { |h, i| h['_path'] = pa + ":#{i}" } }
        .flatten(1)
    end

    def load_hooks(exid)

      hooks(Flor.domain(exid))
        .collect { |h| Flor::Hook.new(@unit, exid, h) }
    end

    def domains(start='')

      Dir[File.join(@root, '**/*.{json,flo,flor,rb}')]
        .collect { |pa| pa[@root.length..-1] }
        .sort
        .collect { |pa|
          pa = pa[4..-1] if pa.match(/^\/usr\//)
          case pa
          when /\.flor?$/ then extract_flow_domain(pa)
          when /\/lib\/hooks\// then extract_hook_domain(pa)
          when /\/lib\/taskers\// then extract_tasker_domain(pa)
          when /\/etc\/variables\// then extract_variable_domain(pa)
          else nil
          end }
        .compact
        .select { |pa| pa.length > 1 }
        .collect { |pa|
          pa = pa[1..-1] if pa[0, 1] == '/'
          pa = pa[0..-2] if pa.match(/\/$/)
          pa.gsub('/', '.') }
        .sort
        .uniq
    end

    protected

    def extract_flow_domain(pa)
#o = pa
      pa
        .gsub(/\/lib\/(sub)?flows\//, '/')
        .split('/')[0..-2].join('/')
#.tap { |x| p 'flow:' + o + ':' + x }
    end
    def extract_hook_domain(pa)
#o = pa
      pa
        .gsub(/\/lib\/hooks\//, '/')
        .gsub(/\/(dot|hooks)\.(json|rb)$/, '/')
        .gsub(/\.(json|rb)$/, '')
#.tap { |x| p 'hook:' + o + ':' + x }
    end
    def extract_tasker_domain(pa)
#o = pa
      pa
        .gsub(/\/lib\/taskers\//, '/')
        .gsub(/\/[^\/]+\/(dot|flor|tasker)\.(json|rb)$/, '/')
        .gsub(/\.(json|rb)$/, '')
#.tap { |x| p 'tasker: ' + o + ': ' + x }
    end
    def extract_variable_domain(pa)
#o = pa
      pa
        .gsub(/\/etc\/variables\//, '/')
        .gsub(/\/(dot|flor)\.(json|rb)$/, '/')
        .gsub(/\.(json|rb)$/, '')
#.tap { |x| p 'variable: ' + o + ': ' + x }
    end

    def split_dn(domain, name)

      if name
        [ domain, name ]
      else
        elts = domain.split('.')
        [ elts[0..-2].join('.'), elts[-1] ]
      end
    end

    def expose_d(path, opts)

      pa = path[@root.length..-1]
      pa = pa[5..-1] if pa[0, 5] == '/usr/'

      libregex =
        opts[:subflows] ?
        /\/lib\/(subflows|flows|hooks|taskers)\// :
        /\/lib\/(flows|hooks|taskers)\//

      pa
        .sub(/\/etc\/variables\//, '/')
        .sub(libregex, '/')
        .sub(/\/\z/, '')
        .sub(/\/(flo|flor|dot|hooks)\.json\z/, '')
        .sub(/\.(flo|flor|json|rb)\z/, '')
        .sub(/\A\//, '')
        .gsub(/\//, '.')
    end

    def expose_dn(path, opts)

      pa = expose_d(path, opts)

      if ri = pa.rindex('.')
        [ pa[0..ri - 1], pa[ri + 1..-1] ]
      else
        [ '', pa ]
      end
    end

    def eval(path, context)

      ext =
        File.extname(path)

      src =
        @mutex.synchronize do

          mt1 = File.mtime(path)
          val, mt0 = @cache[path]

          if val && mt1 == mt0
            val
          elsif ext == '.rb'
            (@cache[path] = [ File.read(path), mt1 ]).first
          else
            (@cache[path] = [ Flor::ConfExecutor.load(path), mt1 ]).first
          end
        end

      case ext
      when '.rb' then eval_ruby(path, src, context)
      else eval_json(path, src, context)
      end
    end

    def eval_json(path, src, context)

      Flor::ConfExecutor.interpret(path, src, context)
    end

    def eval_ruby(path, src, context)

      ks = context.keys.select { |k| k.match(/\A[a-z][a-zA-Z0-9_]+\z/) }

      s = StringIO.new
      s << "lambda {\n"
      ks.each { |k| s << k << " = " << context[k].inspect << "\n" }
      s << src
      s << "\n}.call\n"

      r = Kernel.module_eval(s.string, path, - ks.size)

      r = JSON.parse(JSON.dump(r)) #if r.keys.find { |k| k.is_a?(Symbol) }
        #
        # so that symbols may be used in the .rb file, but plain JSON-like
        # string keys are on the output

      r.merge!('_path' => path)
    end
  end
end

