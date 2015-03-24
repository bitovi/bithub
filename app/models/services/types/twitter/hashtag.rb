module Services
  module Types
    module Twitter
      class Hashtag
        include Virtus.model(:strict => true)
        attribute :hashtag, HashlessString
        attribute :display_name, String, :default => lambda { |obj, attr| "\##{obj.hashtag}" }
      end
    end
  end
end
