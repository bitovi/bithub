require 'spec_helper'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
end
  
GITHUB_400_RESPONSE = {
  body: "{\"message\":\"Whatever.\"}",
  status: "400 Client Error" ,
  response_headers: {"status"=>"400 Client Error"},
  url: 'https://api.github.com/what/ever' 
}
