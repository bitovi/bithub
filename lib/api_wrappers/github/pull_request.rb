require 'github/entity'

module Github
  class PullRequest < Entity

    def initialize(*args)
      data = super

      if data[:number]
        @number = data[:number]
        read
      else
        @base = data[:base]
        @head = data[:head]
        @title = data[:title]
        @body = data[:body] || ""
        create
      end
    end
    
    def create
      response = @connector.create_pull_request @repo, @base, @head, @title, @body
      attach_attributes_from_response(response)
      
      self
    end

    def read
      response = @connector.pull_request @repo, @number
      attach_attributes_from_response(response)
      
      self
    end
    
  end
end

