# frozen_string_literal: true

module Flor

  # A ModuleGanger accepts a `module:` conf entry that points to a Ruby
  # module. The tasker implementations are searched for among the classes
  # in the given module.
  #
  # Among the tasker classes (classes that respond to on_task, on_detask, ...)
  # it selects the first tasker that matches the tasker name.
  #
  class ModuleGanger

    def initialize(service, conf, message)

      @service = service
      @conf = conf
      @message = message
    end

    def task

      tas = @message['tasker']
      clas = list_tasker_classes
      cla = clas.find { |c| tasker_name(c) == tas }

      return [ Flor.dup_and_merge(@message, 'routed' => false) ] \
        unless cla

      call_tasker(cla)
    end

    protected

    def list_tasker_classes

      mod_name = @conf['module']

      fail ArgumentError.new('ganger module: configuration entry missing') \
        unless mod_name

      mod = Flor.const_lookup(mod_name) rescue nil

      fail ArgumentError.new("ganger cannot find module #{mod_name.inspect}") \
        unless mod

      list_classes(mod, [])
    end

    def list_classes(start, r)

      # place leave classes on top if possible
      # within a level, sort alphabetically

      clas = start.constants.collect { |co| start.const_get(co) }
      clas, mods = clas.partition { |c| c.is_a?(Class) }

      mods.each { |m| list_classes(m, r) }
      r.concat(clas.select { |c| tasker?(c) }.sort_by { |c| c.name })

      r
    end

    TASKER_METHODS = [
      :on, :on_message,
      :task, :on_task,
      :detask, :on_detask, :cancel, :on_cancel
        ].freeze

    def tasker?(cla)

      return true if (TASKER_METHODS & cla.public_instance_methods).any?
      return true if (TASKER_METHODS & cla.public_methods).any?
      false
    end

    def tasker_name(cla)

      if cla.public_instance_methods.include?(:tasker_name)

        unless cla.respond_to?(:_ganged)
          class << cla
            attr_accessor :_ganged
          end
          cla._ganged = cla.allocate
        end

        call_tasker_name(cla._ganged)

      elsif cla.public_methods.include?(:tasker_name)

        call_tasker_name(cla)

      else

        cla.name.split('::').last.gsub(/Tasker\z/, '')
          .gsub(/([a-z])([A-Z])/) { |_| $1 + '_' + $2.downcase }
          .gsub(/([A-Z])/) { |c| c.downcase }
      end
    end

    def call_tasker_name(o)

      case i = o.method(:tasker_name).arity
      when 1 then o.tasker_name(@message)
      when 2 then o.tasker_name(@conf, @message)
      when 3 then o.tasker_name(@service, @conf, @message)
      when -1 then o.tasker_name(
        service: @service, conf: @conf, message: @message)
      else o.tasker_name
      end
    end

    def call_tasker(c)

      cnf = @conf.merge('class' => c)

      @service.unit.caller
        .call(@service, cnf, @message)
    end
  end
end

