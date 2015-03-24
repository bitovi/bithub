module Services
  module Types
    module Meetup
      class Group
        include Virtus.model(:strict => true)
        attribute :id, Integer
        attribute :display_name, String, :default => ''
        def humanized_name=(name)
          self.display_name = name
        end
      end
    end
  end
end
