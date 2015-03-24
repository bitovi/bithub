module Services
  module Types
    module Tumblr
      class Blog
        include Virtus.model(:strict => true)
        attribute :hostname, String
        attribute :display_name, String, :default => lambda { |obj, attr| obj.hostname }

        def hostname=(new_hostname)
          uri = URI.parse(new_hostname)
          if uri.scheme.nil? && uri.host.nil? && !(uri.path.nil?)
            uri.scheme = "http"
            uri.host = uri.path
            uri.path = ""
          end

          super uri.hostname.split('.').first
        end
      end
    end
  end
end
