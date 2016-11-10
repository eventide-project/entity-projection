require_relative '../automated_init'

context "Apply" do
  context "Message" do
    message = EntityProjection::Controls::Message.example

    context "Projection Implements Handler for Message" do
      entity = EntityProjection::Controls::Entity::New.example

      EntityProjection::Controls::Projection::Example.(entity, message)

      test "Message is handled" do
        assert(entity.some_attribute == 'some value')
      end
    end

    context "Projection Does Not Implement Handler for Message" do
      entity = EntityProjection::Controls::Entity::New.example

      unchanged_attribute = message.some_attribute

      EntityProjection::Controls::Projection::Anomaly::NoApply::Example.(entity, message)

      test "Message is not handled" do
        assert(message.some_attribute == unchanged_attribute)
      end
    end
  end
end
