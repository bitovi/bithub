module Entities
	module Finders

		module FindableByOriginUID
			def find_by_origin_uid(uid)
				where("props -> 'origin_author_id' = ?", uid)
			end
		end

		module FindableByRepoNameIssueNumber
			def find_by_name_and_number(repo_name, issue_nmb)
				where("props -> 'repo_name' = '#{repo_name}'")
				.where("props -> 'referenced_issue_number' = '#{issue_nmb}'")
			end
		end

	end
end
