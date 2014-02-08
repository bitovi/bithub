require 'domain/spec_helper'
require 'yaml'

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
  Events::Dispatcher.dispatch(load_response(load_path), feed)
end

shared_examples_for "every event" do
  it "has content_digest" do
    expect(payload.content_digest.length).to eq(32)
  end
end
