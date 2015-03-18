module Services
  module Types
    module Instagram
      class Tag
        include Virtus.model(:strict => true)
        attribute :tag, HashlessString
        attribute :display_name, String, :default => lambda { |obj, attr| "\##{obj.tag}" }
      end
    end
  end
end
