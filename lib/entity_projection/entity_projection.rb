module EntityProjection
  def self.included(cls)
    cls.class_exec do
      include Log::Dependency

      cls.extend Build
      cls.extend Call
      cls.extend Info
      # cls.extend ApplyMacro
      cls.extend MessageRegistry

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

    def handler(message_or_event_data)
      name = handler_name(message_or_event_data)

      if method_defined?(name)
        return name
      else
        return nil
      end
    end

    def handles?(message_or_event_data)
      method_defined? handler_name(message_or_event_data)
    end

    def handler_name(message_or_event_data)
      name = nil

      if message_or_event_data.is_a? EventSource::EventData::Read
        name = Messaging::Message::Info.canonize_name(message_or_event_data.type)
      else
        name = message_or_event_data.message_name
      end

      "apply_#{name}"
    end
  end

  module Call
    def call(entity, message_or_event_data)
      instance = build(entity)
      instance.(message_or_event_data)
    end
  end

  module MessageRegistry
    def message_registry
      @message_registry ||= Messaging::MessageRegistry.new
    end
  end

  def call(message_or_event_data)
    # if message_or_event_data.is_a? Message
    #   handle_message(message_or_event_data)
    # else
      handle_event_data(message_or_event_data)
    # end
  end

  def handle_event_data(event_data)
    logger.trace(tags: [:handle, :event_data]) { "Applying event data (Type: #{event_data.type})" }
    logger.trace(tags: [:data, :event_data, :handle]) { event_data.pretty_inspect }

    res = nil

    handler = self.class.handler(event_data)

    unless handler.nil?
      # message_name = Messaging::Message::Info.canonize_name(event_data.type)
      # message_class = self.class.message_registry.get(message_name)
      # res = Message::Import.(event_data, message_class)
      # public_send(handler, res)
    else
      if respond_to?(:apply)
        res = apply(event_data)
      end
    end

    logger.info(tags: [:handle, :event_data]) { "Applied event data (Type: #{event_data.type})" }
    logger.info(tags: [:data, :event_data, :handle]) { event_data.pretty_inspect }

    res
  end
end
