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

      module New
        def self.example
          Entity::SomeEntity.new
        end
      end
    end
  end
end
