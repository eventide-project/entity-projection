module EntityProjection
  module Controls
    module Projection
      class Example
        include EntityProjection
        include Controls::Message

        entity_name :some_entity

        apply SomeMessage do |some_message|
          some_entity.some_attribute = some_message.some_attribute
        end
      end

      module ApplyMethod
        module EventData
          class Example
            include EntityProjection

            def apply(event_data)
              entity.some_attribute = event_data.data[:attribute]
            end
          end
        end

        module Message
          class Example
            include EntityProjection

            def apply(message)
              entity.some_attribute = message.some_attribute
            end
          end
        end
      end

      module BlockAndApplyMethod
        class Example
          include EntityProjection
          include Controls::Message

          apply SomeMessage do |some_message|
            entity.some_attribute = 'some attribute value set by apply block'
          end

          def apply(event_data)
            event_data.data = 'some data value set by apply method'
          end
        end
      end

      module RegisterMessageClass
        class Example
          include EntityProjection
          include Controls::Message

          register SomeMessage
        end
      end

      module Anomaly
        module NoApply
          class Example
            include EntityProjection
          end
        end
      end
    end
  end
end
