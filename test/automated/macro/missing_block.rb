require_relative '../automated_init'

context "Apply" do
  context "Macro" do
    context "Handler Block Without Parameter" do
      define_handler = proc do
        Class.new do
          include EntityProjection

          apply EntityProjection::Controls::Message::SomeMessage
        end
      end

      test "Is an error" do
        assert define_handler do
          raises_error? EntityProjection::ApplyMacro::Error
        end
      end
    end
  end
end
