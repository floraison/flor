# frozen_string_literal: true

module Flor

  class CoreLoader

    def shutdown
    end

    # Called to interpret require: confs from hooks and friends
    #
    def require(conf)

      re = conf['require']

      return unless re

      ::Kernel.require(
        if path = conf['_path']
          File.join(File.dirname(path), re)
        else
          re
        end)
    end
  end

  class Loader < CoreLoader

    # NB: tasker configuration entries start with "loa_"

    def initialize(unit)

      @unit = unit

      @cache = {}
      @mutex = Mutex.new

      @root = File.absolute_path(
        @unit.conf['lod_path'] || @unit.conf['root'] || '.')
    end

    def variables(domain)

      %w[ .json .js .yaml .rb ]
        .inject([]) { |a, x| a + Dir[File.join(@root, "**/*#{x}")] }
        .select { |f| f.index('/etc/variables/') }
        .collect { |pa| [ pa, expose_d(pa, {}) ] }
        .select { |pa, d| Flor.sub_domain?(d, domain) }
        .sort_by { |pa, d| d.count('.') }
        .inject({}) { |vars, (pa, _)| vars.merge!(eval_variables(pa, {})) }
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
          Flor.sub_domain?([ d, n ], domain) ||
          (n == name && Flor.sub_domain?(d, domain)) }
        .sort_by { |pa, d, n| d.count('.') }
        .last

      return nil unless pat

      conf = eval_tasker_conf(pat, message)

      return conf if nam == name

      cnf = conf[name]

      return nil unless cnf

      extras = conf.select { |_, v| ! v.is_a?(Hash) }
      extras['_path'] = pat

      (cnf.is_a?(Array) ? cnf : [ cnf ])
        .each { |h| h.merge!(extras) }

      cnf
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
          eval_hook_conf(pa, {})
            .each_with_index { |h, i| h['_path'] = "#{pa}:#{i}" } }
        .flatten(1)
    end

    def load_hooks(exid)

      hooks(Flor.domain(exid))
        .collect { |h| Flor::Hook.new(@unit, exid, h) }
    end

    def domains(start=nil)

      start ||= ''

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
        .select { |dm| Flor.sub_domain?(start, dm) }
    end

    def definitions(start=nil)

      start ||= ''

      Dir[File.join(@root, '**/*.{flo,flor}')]
        .collect { |pa| pa[@root.length..-1] }
        .collect { |pa| pa.gsub(/\A\/usr\//, '/') }
        .collect { |pa| pa.gsub(/\/lib\/(sub)?flows\//, '/') }
        .collect { |pa| pa.gsub(/\.flor?\z/, '') }
        .collect { |pa| pa.gsub(/\//, '.') }
        .collect { |pa| pa.gsub(/\A\./, '') }
        .sort
        .select { |pa| Flor.sub_domain?(start, pa) }
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
        .sub(/\.(flo|flor|json|js|rb|yaml)\z/, '')
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

    def eval_variables(path, context)
      eval(path, context)
    end
    def eval_tasker_conf(path, context)
      eval(path, context)
    end
# TODO like in eval_hook_conf, reject fautly tasker confs...
# TODO like in eval_hook_conf, reject fautly variables...

    def eval_hook_conf(path, context)

      a = eval(path, context)

      fail ArgumentError.new(
        "hook conf at #{path} must be an array of hashes"
      ) unless a.is_a?(Array)

      a.each do |e|
        fail ArgumentError.new(
          "hook conf at #{path} has non-hash entry #{e.inspect}"
        ) unless e.is_a?(Hash)
        fail ArgumentError.new(
          "hook conf at #{path} has incorrect point #{e['point'].inspect}"
        ) unless e['point'].is_a?(String)
      end

      a
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
          elsif %w[ .rb .yaml ].include?(ext)
            (@cache[path] = [ File.read(path), mt1 ]).first
          else
            (@cache[path] = [ Flor::ConfExecutor.load(path), mt1 ]).first
          end
        end

      case ext
      when '.rb' then eval_ruby(path, src, context)
      when '.js', '.json' then eval_json(path, src, context)
      when '.yaml' then eval_yaml(path, src, context)
      else fail(ArgumentError.new("cannot load variables at #{path}"))
      end
    end

    def eval_json(path, src, context)

      Flor::ConfExecutor.interpret(path, src, context)
    end

    def eval_yaml(path, src, context)

      YAML.load(src)
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

