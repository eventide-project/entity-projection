module EventStore
  module EntityProjection
    def self.included(cls)
      cls.extend Logger
      cls.extend Build
      cls.extend Actuate
      cls.extend ApplyMacro
      cls.extend EntityNameMacro
      cls.extend Info
      cls.extend EventStore::Messaging::Dispatcher::MessageRegistry
      cls.extend EventStore::Messaging::Dispatcher::BuildMessage

      cls.send :attr_reader, :entity
      cls.send :dependency, :reader, EventStore::Messaging::Reader
      cls.send :dependency, :logger, Telemetry::Logger
    end

    module Logger
      def logger
        Telemetry::Logger.get self
      end
    end

    module ApplyMacro
      def apply_macro(message_class, &blk)
        define_handler_method(message_class, &blk)
        message_registry.register(message_class)
      end
      alias :apply :apply_macro

      def define_handler_method(message_class, &blk)
        logger = Telemetry::Logger.get self

        logger.opt_trace "Defining projection method (Message: #{message_class})"

        projection_method_name = handler_name(message_class)
        send(:define_method, projection_method_name, &blk).tap do
          logger.opt_debug "Defined projection method (Method Name: #{projection_method_name}, Message: #{message_class})"
        end
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

    module Info
      extend self

      def handles?(message)
        method_defined? handler_name(message)
      end

      def handler_name(message)
        name = EventStore::Messaging::Message::Info.message_name(message)
        "apply_#{name}"
      end
    end

    module Build
      def build(entity, stream_name, starting_position: nil, slice_size: nil, session: nil)
        new(entity).tap do |instance|
          dispatcher = instance
          EventStore::Messaging::Reader.configure instance, stream_name, dispatcher, starting_position: starting_position, slice_size: slice_size, session: session
          Telemetry::Logger.configure instance
        end
      end
    end

    module Actuate
      def call(entity, stream_name, starting_position: nil, slice_size: nil, session: nil)
        instance = build entity, stream_name, starting_position: starting_position, slice_size: slice_size, session: session
        instance.()
      end
      alias :! :call # TODO: Remove deprecated actuator [Kelsey, Thu Oct 08 2015]
    end

    def initialize(entity)
      @entity = entity
    end

    def call
      logger.trace "Running projection"

      last_event_number = reader.start

      logger.debug "Ran projection (Last Event Number: #{last_event_number.inspect})"

      last_event_number
    end
    alias :! :call # TODO: Remove deprecated actuator [Kelsey, Thu Oct 08 2015]

    def build_message(entry_data)
      self.class.build_message(entry_data)
    end

    def dispatch(message, _)
      if self.class.handles?(message)
        apply message
      end
    end

    def apply(message)
      logger.opt_trace "Applying #{message.class.name} to #{entity.class.name}"
      handler_method_name = Info.handler_name(message)

      send(handler_method_name, message).tap do
        logger.opt_debug "Applied #{message.class.name} to #{entity.class.name}"
        logger.data entity.inspect
      end

      nil
    end
  end
end
