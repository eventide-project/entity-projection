module EntityProjection
  class Log < ::Log
    def tag!(tags)
      tags << :entity_projection
      tags << :library
      tags << :verbose
    end
  end
end
