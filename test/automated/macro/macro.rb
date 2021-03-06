require_relative '../automated_init'

context "Handle" do
  context "Macro" do
    projection = EntityProjection::Controls::Projection::Example.new('some_entity')

    test "Defines apply methods" do
      assert(projection.respond_to? :apply_some_message)
    end

    test "Registers event classes" do
      assert(projection.class.event_registry.registered? EntityProjection::Controls::Message::SomeMessage)
    end
  end
end
