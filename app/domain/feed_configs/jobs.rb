module FeedConfigs
  module Jobs

    class FetchGithubReposJob < Struct.new(:access_token)
      def preform
        conn = create_github_client

        # org repos aren't included in response
        conn.repos.map {|r| r.full_name}
      end
    end

    class FetchGithubOrgsJob < Struct.new(:access_token)
      def preform
        conn = create_github_client
        conn.orgs.map {|o| r.login}
      end
    end

    class FetchMeetupGroupsJob < Struct.new(:access_token)
      def preform

      end
    end

    class FetchFoursquareVenusJob < Struct.new(:access_token)
      def preform

      end
    end

    class FetchDisqusForumsJob < Struct.new(:access_token)
      def preform

      end
    end

    class FetchFacebookPagesJob < Struct.new(:access_token)
      def preform

      end
    end

    private

    def create_github_client(access_token)
      Octokit::Client.new \
        :access_token => access_token,
        :auto_paginate => true
    end

  end
end
