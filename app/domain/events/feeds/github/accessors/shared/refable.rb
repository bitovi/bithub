module Events
  module Github
    module Accessors

      module Refable

        def ref_type
          payload.andand[:ref_type]
        end

        def ref
          payload.andand[:ref].to_s
        end

      end
    end
  end
end
