module Events
  module Github
    module WithLabels

      def referenced_issue_number(original_hash)
        original_hash['payload']['issue']['body']
      end

	  def referenced_repo_name(original_hash)
        original_hash['payload']['issue']['body']
	  end

    end
  end
end
