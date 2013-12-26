require 'entities/feeds/blog/types/post'
require 'entities/procurer'

module Entities
  module Blog

    class Procurer < Entities::Procurer
      def procure(event, payload)
        procurer = Entities::Blog::Post::Procurer.new(@p)
        procurer.procure(event, payload)
      end
    end

  end
end
