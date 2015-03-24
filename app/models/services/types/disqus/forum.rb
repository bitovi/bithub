module Services
  module Types
    module Disqus
      class Forum
        include Virtus.model(:strict => true)
        attribute :url, String
        attribute :display_name, String, default: lambda { |obj, attr| obj.url }
      end
    end
  end
end
