require 'octokit'

module Github
  class Entity
    attr_accessor :last_response
    
    def initialize(*args)
      
      case
      when args.length >= 4
        @login = args.shift
        @password = args.shift
        @repo = args.shift
        @connector = Octokit::Client.new :login => @login, :password => @password
        args[0] # data hash
      when args.length >= 3
        @access_token = args.shift
        @repo = args.shift
        @connector = Octokit::Client.new :access_token => @access_token
        args[0] # data hash
      else
        nil
      end

    end

    def last_response
      @connector.last_response
    end
      
    private

    def attach_attributes_from_response(response)
      attach_attributes(sawyer_fields_to_hash(response))
    end

    def attach_attributes(attrs)
      attrs.keys.each do |key|
        self.instance_variable_set("@#{key}", attrs[key])
        self.class.send :attr_accessor, key.to_sym
      end
    end

    def sawyer_fields_to_hash(obj)
      return obj unless obj.respond_to?(:_fields)

      Hash[ obj.fields.map do |f|
              if obj[f].kind_of?(Array)
                [f, obj[f].map {|e| sawyer_fields_to_hash(e)}]
              else
                [f, sawyer_fields_to_hash(obj[f])]
              end
            end
          ]
    end

    def instance_variables_to_hash
      Hash[ self.instance_variables.map do |attr|
              [attr[1..-1].to_sym, self.instance_variable_get(attr)]
            end
          ]
    end
    
  end
end
