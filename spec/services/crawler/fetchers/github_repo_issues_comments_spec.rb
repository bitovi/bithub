require 'spec_helper'
require_relative 'fetchers_spec_helper'
require 'github_api'

require 'fetchers/github/repo_issues_comments'

describe Fetchers::Github::RepoIssuesComments do

  let(:client) do
    ::Github.new basic_auth: 'bitovi-bithub-test:wyHM2PfTCCwE'
  end

  describe '#fetch' do
    it 'fetches all comments for all issues of a repo' do
      f = Fetchers::Github::RepoIssuesComments.new(client, { user_repo: 'bithub-test/bithub-test-repo' })
      VCR.use_cassette('bithub_test_repo_issue_comments') do
        expect(f.fetch.length).to eq 1
      end
    end
  end
end
