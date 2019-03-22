require_relative 'automated_init'

context "Register" do
  projection = EntityProjection::Controls::Projection::RegisterMessageClass::Example.new('some_entity')

  test "Registers event classes" do
    assert(projection.class.event_registry.registered? EntityProjection::Controls::Message::SomeMessage)
  end
end
