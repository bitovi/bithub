require 'spec_helper'
require 'app/processor'

require 'spec/processors/shared_specs'
require 'spec/processors/github_spec'
require 'spec/processors/twitter_spec'
require 'spec/processors/disqus_spec'
require 'spec/processors/blog_spec'
require 'spec/processors/forums_spec'

describe Processor do
  describe "#new" do
    context "when given a block" do
      it "should construct the processor based on config hash it receives"
    end
  end
end
