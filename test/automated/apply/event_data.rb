require_relative '../automated_init'

context "Apply" do
  context "EventData" do
    event_data = EntityProjection::Controls::EventData::Read.example
    event_data.data[:attribute] = 'some value'

    context "Projection Implements Apply" do
      entity = EntityProjection::Controls::Entity::New.example

      EntityProjection::Controls::Projection::ApplyMethod::Example.(entity, event_data)

      test "Event data is projected" do
        assert(entity.some_attribute == 'some value')
      end
    end

    context "Projection Does Not Implement Apply" do
      entity = EntityProjection::Controls::Entity::New.example
      entity.some_attribute = SecureRandom.hex
      unchanged_data = entity.some_attribute

      EntityProjection::Controls::Projection::Anomaly::NoApply::Example.(entity, event_data)

      test "Event data is not projected" do
        assert(entity.some_attribute == unchanged_data)
      end
    end
  end
end
