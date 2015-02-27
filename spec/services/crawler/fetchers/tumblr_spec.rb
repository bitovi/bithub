require 'spec_helper'
require_relative 'fetchers_spec_helper'

require 'fetchers/tumblr/posts'

describe Fetchers::Tumblr::Posts  do

  describe '#fetch' do
    it 'fetches all comments for all issues of a repo' do
      VCR.use_cassette('tumblr_posts') do
        result = Fetchers::Tumblr::Posts.fetch 'puuluu.tumblr.com', limit: 1
        expect(result.length).to eq 1
      end
    end

  end
end
