require 'spec_helper'
require 'evented-spec'
require 'amqp'
require 'uri'
require 'yajl'

# ours
require "./spec/integration_testing/helpers.rb"
require 'github'
require 'bithub'

$config = Helpers.load_config
$rabbitmq = $config[:rabbitmq]
$user1 = $config[:github][:users][0]
$repo1 = $config[:github][:repos][0]

### NOTE: THESE TESTS ARE MEANT TO BE RUN IN DEFAULT ORDER
###       (hint: use 'rspec --order default'


describe "Handling Github issues" do
  include EventedSpec::AMQPSpec

  default_options :host  => $rabbitmq[:host] || "127.0.0.1"
  default_options :port  => $rabbitmq[:port] || "5672"
  default_options :user  => $rabbitmq[:user] || "guest"
  default_options :pass  => $rabbitmq[:pass] || "guest"
  default_options :vhost => $rabbitmq[:vhost] || "/"
  default_timeout 60
  
  amqp_before do
    @channel = AMQP::Channel.new
    @exchange = @channel.fanout("e.events.liveservice")
  end
  
  it "raises an issue with label 'bug'" do

    # raise an issue
    data = {
      :title => Helpers.unique_string,
      :body => "Raising an issue with label 'bug'.",
      :labels => ['bug']
    }
    issue = Github::Issue.new $user1[:username], $user1[:password], $repo1[:name], data

    # check if request was successful
    expect(issue.last_response.status).to eq 201

    # listen on MQ for new event and check response
    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)

      # match event on the MQ
      if event[:title].include?(issue.title)

        # fetch event via Bithub API
        api_event = Bithub::Event.new 'http://bithub.dev', {:id => event[:id]}

        # examine
        expect(api_event.body).to include("Raising an issue") # response body is wrapped within <p>
        expect(api_event.tags).to include("bug","github","issues_event")
        expect(api_event.feed).to eq "github"
        expect(api_event.category).to eq "bug"

        #expect(api_event.author).to eq "foobar"
        # check author points

        # stop listening
        done
      end
      
    end

  end

  it "updates issue with label 'enhancement' (old labels are removed)"
  
  it "closes an issue"
  
  it "posts a comment on issue"
  
  it "references issue within commit message" do

    # push to github repo
    identifier = Helpers.unique_string
    Helpers.git_create_push($repo1[:local_path], identifier + " #issue_num", ['reference_issue_test.txt'])

    # listen on MQ for new event and check response
    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)
      
      if event[:props][:type] == 'push_event' && event[:title].include?($repo1[:name])
        api_event = Bithub::Event.new 'http://bithub.dev', {:id => event[:id]}
        
        expect(api_event.children.length).to eq 1
        
        #expect(event[:body]).to eq issue.body
        #expect(event[:tags]).to include *(issue.labels.map {|l| l[:name]})
        #expect(event[:category]).to eq "bug"
        #expect(event[:author]).to eq "bug"
        #expect(event[:feed]).to eq "github"
        # check author points
        
        done
      end
    end
  end
  
end
