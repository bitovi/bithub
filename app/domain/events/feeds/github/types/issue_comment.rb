module Events
  module Github

    class IssueComment
      include Constructable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::IssuesPullRequests
      include Events::Github::Accessors::Comments
    end

  end
end
