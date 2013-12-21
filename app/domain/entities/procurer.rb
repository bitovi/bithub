module Entities
  class Procurer
    include FindableByOriginUID

    def initialize(persistor)
      @p = persistor
    end

    def find_or_build(payload)
      attrs = extract(payload)

      if e = find(attrs)
        return e
      elsif e = build(attrs)
        return e
      else
        # FAIL?
      end
    end

    def find_or_build_upstream(attrs)
      attrs = extract(payload)
      Relationships[:upstream].map {|ec| ec::Procurer.new(@p).find_or_build(attrs) }
    end
    
    def find_or_build_downstream(attrs)
      attrs = extract(payload)
      Relationships[:downstream].map {|ec| ec::Procurer.new(@p).find_or_build(attrs) }
    end

    def build(attrs)
      @p.new(attrs)
    end

    def extract(payload)
      payload['extracted']
    end
  end

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
