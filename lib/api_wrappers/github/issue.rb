require 'github/entity'

module Github
  class Issue < Entity
    FIELDS = [:title, :body, :number, :assignee, :state, :milestone, :labels]
    
    attr_accessor *FIELDS

    def initialize(*args)
      data = super

      if data[:number]
        @number = data[:number]
        read
      else
        attach_attributes( Hash[ FIELDS.map {|f| [f, data[f]] if data[f]} ])
      end

    end

    def attributes
      FIELDS
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
      response = @connector.update_issue @repo, @number, @title, @body, {:labels => @labels} #instance_variables_to_hash()
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
