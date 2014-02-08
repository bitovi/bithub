module Entities
  module Bithub
    class Post < Protocol; end

    def self.type(arg)
      Entities::Bithub::Post
    end

  end
end

require_relative 'types/post'
