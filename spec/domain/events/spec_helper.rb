require 'domain/spec_helper'

require 'events/processor'
require 'events/protocol'

def load_and_parse(path)
  ext_name = File.extname(path).gsub('.','').to_sym

  loaders = {
    json: lambda {|p| ActiveSupport::JSON.decode(File.read(path)) },
    rss: lambda {|p| Nori.new(:parser => :nokogiri).parse(File.read(path)) }
  }

  loaders[ext_name].(path)
end

def raw_data(opts = {})
  load_and_parse File.join('spec/support/responses', opts[:response_path])
end
