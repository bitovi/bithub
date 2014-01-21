require 'domain/spec_helper'

def load_response(path)
  loaders = {
    json: Proc.new {|p| YAML::load_file(p)},
    xml: Proc.new {|p| Nori.new(:parser => :nokogiri).parse(IO.read()) }
  }
  loaders[File.extname(path).gsub(/\./,'').to_sym].call path
end

def build_payload(feed, type, opts = {})
  response_path = opts[:response_path] || "#{feed}/#{type}.json"
  load_path = File.join(['spec/support/responses', response_path])
  Events::Payload.new(load_response(load_path), feed)
end

shared_examples_for "every event" do
  it "has content_digest" do
    expect(payload.content_digest.length).to eq(32)
  end
end

require 'spec/domain/events/feeds/twitter_spec'
require 'spec/domain/events/feeds/github_spec'
#require 'spec/domain/events/feeds/blog_spec'
#require 'spec/domain/events/feeds/forum_spec'
#require 'spec/domain/events/feeds/disqus_spec'

# require 'spec/domain/events/feeds/bithub_spec'
# require 'spec/domain/events/feeds/irc_spec'
# require 'spec/domain/events/feeds/meetup_spec'
# require 'spec/domain/events/feeds/stack_exchange_spec'

