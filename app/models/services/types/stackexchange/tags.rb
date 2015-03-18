module Services
  module Types
    module Stackexchange
      class Tags
        include Virtus.model(:strict => true)
        attribute :tags, Array[HashlessString]
        attribute :display_name, String, default: lambda {|obj, attr| obj.tags.map{|t| "\##{t}"}.join(',')}
      end
    end
  end
end
