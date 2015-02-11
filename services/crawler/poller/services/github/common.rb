require 'github_api'

module Supervisors::Services::Github
  module Common
    def client
      ::Github.new(oauth_token: token)
    end
  end
end
