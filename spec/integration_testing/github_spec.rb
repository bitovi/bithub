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

  before(:all) do
    @issue = Github::Issue.new $user1[:username], $user1[:password], $repo1[:name], {
      :title => Helpers.unique_string,
      :body => "Raising an issue with label 'bug'.",
      :labels => ['bug']
    }
    @issue_bithub = Bithub::Event.new 'http://bithub.dev', {}
    @actor = Bithub::User.new 'http://bithub.dev', {:id => 45}
  end
  
  it "raises an issue with label 'bug'" do

    # raise an issue
    @issue.create

    # check if request was successful
    expect(@issue.last_response.status).to eq 201

    # listen on MQ for new event and check response
    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)

      # match event on the MQ
      if event[:title].include?(@issue.title)

        # fetch event via Bithub API
        @issue_bithub.id = event[:id]
        @issue_bithub.read
        
        # examine
        expect(@issue_bithub.body).to include("Raising an issue") # response body is wrapped within <p>
        expect(@issue_bithub.tags).to include("bug","github","issues_event")
        expect(@issue_bithub.feed).to eq "github"
        expect(@issue_bithub.category).to eq "bug"

        # check user
        previous_score = @actor.score
        @actor.read
        expect(@issue_bithub.author[:id]).to eq @actor.id
        expect(@actor.score).to be > previous_score
        
        # stop listening
        done
      end
      
    end

  end

  it "updates issue with label 'enhancement' (old labels are removed)" do

    @issue.labels = ['enhancement']
    @issue.update
    
    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)

      if event[:title].include?(@issue.title)
        @issue_bithub.read
        expect(@issue_bithub.tags).to include("feature","github","issues_event")
        expect(@issue_bithub.tags).not_to include("bug")
        expect(@issue_bithub.category).to eq "feature"
        
        done
      end      
    end
  end
  
  it "closes an issue" do
    @issue.close

    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)

      if event[:title].include?(@issue.title)

        # check closing event
        api_event = Bithub::Event.new 'http://bithub.dev', {:id => event[:id]}
        expect(api_event.parent_id).to eq @issue_bithub.id        
        expect(api_event.source_data[:payload][:issue][:state]).to eq "closed"
        
        # check parent event
        @issue_bithub.read
        expect(@issue_bithub.props[:state]).to eq "closed"
        
        done
      end
    end
  end

  it "reopens an issue" do
    @issue.reopen

    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)

      if event[:title].include?(@issue.title)

        # check reopening event
        api_event = Bithub::Event.new 'http://bithub.dev', {:id => event[:id]}
        expect(api_event.parent_id).to eq @issue_bithub.id        
        expect(api_event.source_data[:payload][:issue][:state]).to eq "open"

        # check parent event
        @issue_bithub.read
        expect(@issue_bithub.props[:state]).to eq "open"

        done
      end
    end
  end

  it "posts a comment on issue" do
    identifier = Helpers.unique_string()
    
    @issue.post_comment(identifier)

    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)

      if event[:body].include?(identifier)

        api_event = Bithub::Event.new 'http://bithub.dev', {:id => event[:id]}
        expect(api_event.parent_id).to eq @issue_bithub.id
        expect(api_event.tags).to include("comment","github","issue_comment_event")
        expect(api_event.feed).to eq "github"
        expect(api_event.category).to eq "comment"

        done
      end
    end
    
  end
  
  it "references issue within commit message" do

    # push to github repo
    message = Helpers.unique_string + "#" + @issue.number
    Helpers.git_create_push($repo1[:local_path], message, ['reference_issue_test.txt'])

    # listen on MQ for new event and check response
    @queue = @channel.queue("q.events.testing.github", :auto_delete => true)
    @queue.bind(@exchange).subscribe do |payload|
      event = Yajl::Parser.parse(payload, :symbolize_keys => true)
      
      if event[:props][:type] == 'push_event' && event[:title].include?($repo1[:name])

        # examine push event
        api_event = Bithub::Event.new 'http://bithub.dev', {:id => event[:id]}        
        expect(api_event.children.length).to eq 1

        # check commit event itself
        
        done
      end
    end
  end
  
end
