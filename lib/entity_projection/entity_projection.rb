module EntityProjection
  def self.included(cls)
    cls.class_exec do
      Initializer.activate(self)

      include Log::Dependency

      extend Build
      extend Call
      extend Info
      extend ApplyMacro
      extend EventRegistry
      extend EntityNameMacro

      virtual :configure

      initializer :entity
    end
  end

  module Build
    def build(entity)
      instance = new(entity)
      instance.configure
      instance
    end
  end

  module Info
    extend self

    def handler(event_or_event_data)
      name = handler_name(event_or_event_data)

      if method_defined?(name)
        return name
      else
        return nil
      end
    end

    def handles?(event_or_event_data)
      handler_name = self.handler_name(event_or_event_data)

      method_defined?(handler_name)
    end

    def handler_name(event_or_event_data)
      name = nil

      if event_or_event_data.is_a?(MessageStore::MessageData::Read)
        name = Messaging::Message::Info.canonize_name(event_or_event_data.type)
      else
        name = event_or_event_data.message_name
      end

      "apply_#{name}"
    end
  end

  module ApplyMacro
    class Error < RuntimeError; end

    def logger
      @logger ||= Log.get(self)
    end

    def apply_macro(event_class, &blk)
      define_apply_method(event_class, &blk)
      event_registry.register(event_class)
    end
    alias :apply :apply_macro

    def define_apply_method(event_class, &blk)
      apply_method_name = handler_name(event_class)

      if blk.nil?
        error_msg = "Handler for #{event_class.name} is not correctly defined. It must have a block."
        logger.error { error_msg }
        raise Error, error_msg
      end

      send(:define_method, apply_method_name, &blk)

      apply_method = instance_method(apply_method_name)

      unless apply_method.arity == 1
        error_msg = "Handler for #{event_class.name} is not correctly defined. It can only have a single parameter."
        logger.error { error_msg }
        raise Error, error_msg
      end

      apply_method_name
    end
  end

  module Call
    def call(entity, event_or_event_data)
      instance = build(entity)
      instance.(event_or_event_data)
    end
  end

  module EventRegistry
    def event_registry
      @event_registry ||= Messaging::MessageRegistry.new
    end
  end

  module EntityNameMacro
    def entity_name_macro(entity_name)
      send(:define_method, entity_name) do
        entity
      end
    end
    alias :entity_name :entity_name_macro
  end

  def call(event_or_event_data)
    if event_or_event_data.is_a?(Messaging::Message)
      apply_event(event_or_event_data)
    else
      apply_event_data(event_or_event_data)
    end
  end

  def apply_event(event)
    logger.trace(tags: [:apply, :message]) { "Applying event (Event class: #{event.class.name})" }
    logger.trace(tags: [:data, :message, :apply]) { event.pretty_inspect }

    handler = self.class.handler(event)

    unless handler.nil?
      public_send(handler, event)
    end

    logger.info(tags: [:apply, :message]) { "Applied event (Event class: #{event.class.name})" }
    logger.trace(tags: [:data, :message, :apply]) { event.pretty_inspect }

    event
  end

  def apply_event_data(event_data)
    logger.trace(tags: [:apply, :event_data]) { "Applying event data (Type: #{event_data.type})" }
    logger.trace(tags: [:data, :event_data, :apply]) { event_data.pretty_inspect }

    res = nil

    handler = self.class.handler(event_data)

    unless handler.nil?
      event_name = Messaging::Message::Info.canonize_name(event_data.type)
      event_class = self.class.event_registry.get(event_name)
      res = Messaging::Message::Import.(event_data, event_class)
      public_send(handler, res)
    else
      if respond_to?(:apply)
        res = apply(event_data)
      end
    end

    logger.info(tags: [:apply, :event_data]) { "Applied event data (Type: #{event_data.type})" }
    logger.info(tags: [:data, :event_data, :apply]) { event_data.pretty_inspect }

    res
  end
end
