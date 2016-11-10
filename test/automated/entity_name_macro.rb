require_relative 'automated_init'

context "Entity Name Macro" do
  entity = EntityProjection::Controls::Entity::New.example

  projection = EntityProjection::Controls::Projection::Example.new(entity)

  test "Defines named named entity accessor" do
    assert(projection.respond_to? :some_entity)
  end

  test "Accesses the entity" do
    assert(projection.some_entity == projection.entity)
  end
end
