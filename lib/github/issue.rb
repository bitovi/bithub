require 'github/entity'

module Github
  class Issue < Entity
    attr_accessor :title, :body

    #FIELDS = [:title, :body, :assignee, :state, :milestone, :labels]
    
    def initialize(*args)
      data = super

      if data[:number]
        @number = data[:number]
        read
      else
        @title = data[:title] || ""
        @body = data[:body] || ""
        @labels = data[:labels] || []
        
        # copy all data to instance variables
        
        create
      end

    end

    def create
      response = @connector.create_issue @repo, @title, @body, instance_variables_to_hash()
      attach_attributes_from_response(response)
      
      self
    end

    def read
      response = @connector.issue @repo, @number
      attach_attributes_from_response(response)

      self
    end

    def update      
      response = @connector.update_issue @repo, @number, data[:title], data[:body], instance_variables_to_hash()
      attach_attributes_from_response(response)

      self
    end
    
    def close
      @connector.close_issue @repo, @number
      self
    end

    def reopen
      @connector.reopen_issue @repo, @number
      self
    end

    def post_comment(comment)
      @connector.add_comment @repo, @number, comment
      self
    end
    
  end
end
