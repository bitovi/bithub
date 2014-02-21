module Events
  module Github
    module Accessors

      class Issue
        include CoreHelpers
        include IssueLike

        def initialize(issue)
          @i = symbolize_keys(issue)
        end
        
        def raw
          @i
        end

        def references_to
          Reference.scan_for_refs(body)
        end
        
      end
    
    end
  end
end
