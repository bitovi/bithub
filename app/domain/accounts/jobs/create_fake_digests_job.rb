module Accounts
  module Jobs

    class CreateFakeDigestsJob < Struct.new(:ident_uid)
      def perform
        if (ident = Identity.find_by_uid(ident_uid))
          FakeDigestsCreator.new(ident).execute
        end
      end
    end

  end
end
