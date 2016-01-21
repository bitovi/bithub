module Fetchers
  module Github
    module UnknownGithubErrorHandler

      def handle_unknown_response(resp)
        if resp.success?
          resp
        elsif resp.redirect? && block_given?
          reset_settings_from_redirect(resp)
          yield 
        else
          [ ]
        end
      end

    end
  end
end
