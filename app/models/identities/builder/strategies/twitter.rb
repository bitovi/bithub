module Identities
  class Builder
    module Strategies
      class Twitter < Identities::Builder::Protocol

        def extract_credentials
          @result[:credentials] = super.merge({
            access_secret: @source_data.fetch(:credentials).fetch(:secret)
          })
        end
      end
    end
  end
end
