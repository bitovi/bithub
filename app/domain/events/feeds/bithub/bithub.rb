require_relative 'types/post'

module Events
  module Bithub
    class Post < Protocol; end

    def self.type(source_data)
      Events::Bithub::Post
    end
    
  end
end
