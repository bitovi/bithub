module Services
  module Types
    module Github
      class Org
        include Virtus.model(:strict => true)
        attribute :name, String
        attribute :display_name, String, default: lambda {|obj, attr| obj.name}
      end
    end
  end
end
