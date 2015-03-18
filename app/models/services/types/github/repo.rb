module Services
  module Types
    module Github
      class Tracking
        include Virtus.model
        attribute :issues, Boolean, default: false
        attribute :pull_requests, Boolean, default: false
      end

      class Repo
        include Virtus.model(:strict => true)
        attribute :name, String
        attribute :tracking, Tracking
        attribute :display_name, String, default: lambda {|obj, attr| obj.name}
      end
    end
  end
end
