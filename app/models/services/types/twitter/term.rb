module Services
  module Types
    module Twitter
      class Term
        include Virtus.model(:strict => true)
        attribute :term, String
        attribute :display_name, String, :default => lambda { |obj, attr| obj.term }
      end
    end
  end
end
