
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

      class << @unit; include Flor::HashLoader::UnitAdders; end

      self.environment = (@unit.conf['lod_environment'] || {})
    end

    def shutdown
    end

    HCATS = {
      'v' => 'variables',
      'var' => 'variables',
      'variable' => 'variables',
      'flo' => 'libraries',
      'flow' => 'libraries',
      'lib' => 'libraries',
      'library' => 'libraries',
      'sub' => 'sublibraries',
      'sublib' => 'sublibraries',
      'sublibrary' => 'sublibraries',
      'tasker' => 'taskers',
      'hook' => 'hooks' }
    CATS =
      HCATS.values.uniq

    def add(cat, path, value, &block)

      c = recat(cat)

      path = path.to_s
      path = path + '.' if c == 'hooks' && path.length > 0 && path[-1, 1] != '.'

      value = block ?
        block_to_class(c, block) :
        Flor.to_string_keyed_hash(value)

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

      libs = entries('libraries', path)
      if opts[:subflows] # used by "graft"/"import"
        libs += entries('sublibraries', path)
        libs = libs.sort_by { |pa, _, _| pa.count('.') }
      end

      libs
        .each { |pa, ke, va|
          next unless ke == key
          return [ [ pa, ke ].join('.'), va ] }

      nil
    end

    def tasker(domain, name, message={})

      path, key = split(domain, name)

      entries('taskers', path)
        .reverse # FIXME
        .each { |pa, ke, va|
          next unless ke == key
          return to_conf_h('taskers', pa, va, message) }

      nil
    end

    def hooks(domain)

      entries('hooks', domain)
        .collect { |_, _, va| to_conf_h('hooks', domain, va, {}) }
        .flatten(1)
    end

    def load_hooks(exid)

      hooks(Flor.domain(exid))
        .collect { |h| Flor::Hook.new(@unit, exid, h) }
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

      (@environment[cat.to_s] || [])
        .select { |path, _, _| Flor.sub_domain?(path, domain) }
    end

    def to_conf_h(cat, path, value, context)

      is_array = value.is_a?(Array)

      a = (is_array ? value : [ value ])
        .collect { |v|
          h =
            case v
            when String then eval(path, v, context)
            when Class then { 'class' => v }
            when Hash then v
            else { 'instance' => v }
            end
          h['_path'] = path
          h['root'] = nil
          h }

      is_array ? a : a.first
    end

    def eval(path, code, context)

      code = Flor::ConfExecutor.load(code)

      Flor::ConfExecutor.interpret(path, code, context)
    end

    def block_to_class(cat, block)

      c =
        cat == 'taskers' ?
        Class.new(Flor::BasicTasker) :
        Class.new

      class << c; attr_accessor :source_location; end
      c.source_location = block.source_location
      c.send(:define_method, :on_message, &block)

      c
    end

    module UnitAdders

      def add_variable(path, value)
        self.loader.add(:variable, path, value)
      end
      def add_library(path, value)
        self.loader.add(:library, path, value)
      end
      def add_sublibrary(path, value)
        self.loader.add(:sublibrary, path, value)
      end
      def add_tasker(path, value=nil, &block)
        self.loader.add(:tasker, path, value, &block)
      end
      def add_hook(path, value=nil, &block)
        self.loader.add(:hook, path, value, &block)
      end

      alias add_var add_variable
      alias add_lib add_library
      alias add_sub add_sublibrary
      alias add_sub_lib add_sublibrary

      # to remove: unit.loader.remove(:tasker, path)
    end
  end
end

