require 'yajl'
require 'net/http'

module Bithub
  
  class Entity
    attr_accessor :id  

    def initialize(*args)
      @endpoint = args.shift
      args[0] # data hash
    end

    private

    def attach_attributes(attrs)
      attrs.keys.each do |key|
        self.instance_variable_set("@#{key}", attrs[key])
        self.class.send :attr_accessor, key.to_sym
      end
    end

    def get(path)
      response = Net::HTTP.get_response(URI(@endpoint + path))
      parsed = Yajl::Parser.parse(response.body, :symbolize_keys => true)
      parsed[:data] || parsed
    end
    
  end

  
  class Event < Entity

    def initialize(*args)
      data = super

      if data[:id]
        @id = data[:id]
        read
      else
        attach_attributes(data)
      end
      
    end

    def read
      response = get("/api/events/" + @id.to_s)
      attach_attributes(response)
      
      self
    end

  end

  class User < Entity

    def initialize(endpoint, id=nil)
      data = super

      if data[:id]
        @id = data[:id]
        read
      elsif data[:email]
        @email = data[:email]
        read
      else
        attach_attributes(data)
      end
    end

    def read
      if @id
        response = get("/api/users/" + @id.to_s)
        attach_attributes(response)
      elsif @email
        response = get("/api/users/?email=" + @email.to_s)
        attach_attributes(response.first) if response.kind_of?(Array)
      end
      
      self      
    end

  end
  
end
