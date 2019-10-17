require_relative '../automated_init'

context "Apply" do
  context "Macro" do
    context "Handler Block Without Parameter" do
      test "Is an error" do
        assert_raises(EntityProjection::ApplyMacro::Error) do
          Class.new do
            include EntityProjection

            apply EntityProjection::Controls::Message::SomeMessage
          end
        end
      end
    end
  end
end
