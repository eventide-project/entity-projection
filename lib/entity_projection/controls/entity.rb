module EntityProjection
  module Controls
    module Entity
      def self.example
        SomeEntity.build
      end

      class SomeEntity
        include Schema::DataStructure

        attribute :some_attribute
        attribute :other_attribute
      end
    end
  end
end
