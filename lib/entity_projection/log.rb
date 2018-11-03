module EntityProjection
  class Log < ::Log
    def tag!(tags)
      tags << :projection
    end
  end
end
