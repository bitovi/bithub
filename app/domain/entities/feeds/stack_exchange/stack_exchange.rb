module Entities
  module StackExchange
    class Question < Protocol; end
    class Answer < Protocol; end
    class Comment < Protocol; end
  end
end

require_relative 'types/question'
require_relative 'types/answer'
require_relative 'types/comment'
