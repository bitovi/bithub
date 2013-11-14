require 'yajl'
require 'net/http'

module Bithub

  class Entity

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

    def request(path)
      response = Net::HTTP.get_response(URI("http://bithub.dev" + path))
      parsed = Yajl::Parser.parse(response.body, :symbolize_keys => true)
      parsed[:data]
    end
    
  end

  
  class Event < Entity

    def initialize(*args)
      data = super

      if data[:id]
        @id = data[:id]
        read
      else
        # copy attrs
        # create
      end
      
    end

    def read
      response = request("/api/events/?id=" + @id.to_s)
      attach_attributes(response[0])
      
      self
    end

  end

  class User < Entity

    def initialize(endpoint, id=nil)
      
    end

  end
  
end
