module Events
  module Github

    class Member < Protocol
      include Events::Github::Accessors::Standard

      def member_name
        payload.andand[:member][:login]
      end
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "Member #{event['payload']['member']['login']} added to #{event['repo']['name']}"
#   }
# })
