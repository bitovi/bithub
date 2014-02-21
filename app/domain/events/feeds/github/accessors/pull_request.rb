module Events
  module Github
    module Accessors

      class PullRequest
        include CoreHelpers
        include IssueLike

        def initialize(pull_req)
          @pr = symbolize_keys(pull_req)
        end
        
        def raw
          @pr
        end
        
        def references_to
          Reference.scan_for_refs(body)
        end
      end
    
    end
  end
end
