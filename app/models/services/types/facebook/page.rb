module Services
  module Types
    module Facebook
      class Page
        include Virtus.model(:strict => true)
        attribute :id, String
        attribute :display_name, String, :default => ''
        def humanized_name=(name)
          self.display_name = name
        end
      end
    end
  end
end
