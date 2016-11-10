require_relative '../automated_init'

context "Apply" do
  context "EventData" do
    context "Projection Implements Message Handler for EventData's Type" do
      event_data = EntityProjection::Controls::EventData::Read.example(type: 'SomeMessage')

      context "Message Handler" do
        entity = EntityProjection::Controls::Entity::New.example

        message = EntityProjection::Controls::Projection::BlockAndApplyMethod::Example.(entity, event_data)

        test "EventData is projected as Message" do
          assert(message.is_a? Messaging::Message)
          assert(entity.some_attribute == 'some attribute value set by apply block')
        end
      end

      context "EventData Handler" do
        entity = EntityProjection::Controls::Entity::New.example

        message = EntityProjection::Controls::Projection::BlockAndApplyMethod::Example.(entity, event_data)

        test "EventData is not handled as EventData" do
          refute(entity.some_attribute == 'some data value set by apply method')
        end
      end
    end
  end
end
