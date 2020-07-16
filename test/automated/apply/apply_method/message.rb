require_relative '../../automated_init'

context "Apply" do
  context "Apply Method" do
    context "Event" do
      message = EntityProjection::Controls::Message.example

      context "Projection Implements Apply" do
        entity = EntityProjection::Controls::Entity::New.example

        EntityProjection::Controls::Projection::ApplyMethod::Message::Example.(entity, message)

        test "Event data is projected" do
          assert(entity.some_attribute == 'some value')
        end
      end

      context "Projection Does Not Implement Apply" do
        entity = EntityProjection::Controls::Entity::New.example
        entity.some_attribute = SecureRandom.hex
        unchanged_data = entity.some_attribute

        EntityProjection::Controls::Projection::Anomaly::NoApply::Example.(entity, message)

        test "Event data is not projected" do
          assert(entity.some_attribute == unchanged_data)
        end
      end
    end
  end
end
