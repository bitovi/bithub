require 'domain/entities/spec_helper'

describe Entities::Procurer do

  before :each do
    @pl_commit_comment = double()
    @pl_commit_comment.stub(:feed => "Github")
    @pl_commit_comment.stub(:type => "CommitComment")
    @pl_commit_comment.stub(:repo_name => "bitovi/canjs")
    @pl_commit_comment.stub(:body => "Lorem ipsum ...")
    @pl_commit_comment.stub(:html_url => "http://github.com/foobar")
    @pl_commit_comment.stub(:commit_id => "12345")
    @pl_commit_comment.stub(:switch_to_camel_case => lambda {})

    @pl_issue_comment = double()
    @pl_issue_comment.stub(:feed => "Github")
    @pl_issue_comment.stub(:type => "IssueComment")
    @pl_issue_comment.stub(:repo_name => "bitovi/canjs")
    @pl_issue_comment.stub(:body => "Lorem ipsum")
    @pl_issue_comment.stub(:html_url => "http://github.com/foobar")
    @pl_issue_comment.stub(:number => "123")
    @pl_issue_comment.stub(:label_names => "foo,bar")
    @pl_issue_comment.stub(:comment_id => "456")
    @pl_issue_comment.stub(:switch_to_camel_case => lambda {})

    @pl_issue = double()
    @pl_issue.stub(:feed => "Github")
    @pl_issue.stub(:type => "Issue")
    @pl_issue.stub(:repo_name => "bitovi/canjs")
    @pl_issue.stub(:title => "foobar")    
    @pl_issue.stub(:body => "Lorem ipsum")
    @pl_issue.stub(:html_url => "http://github.com/foobar")
    @pl_issue.stub(:number => "123")
    @pl_issue.stub(:issue_id => "456")
    @pl_issue.stub(:label_names => "foo,bar")
    @pl_issue.stub(:state => "open")
    @pl_issue.stub(:switch_to_camel_case => lambda {})

    @pl_pull_req = double()
    @pl_pull_req.stub(:feed => "Github")
    @pl_pull_req.stub(:type => "PullRequest")
    @pl_pull_req.stub(:repo_name => "bitovi/canjs")
    @pl_pull_req.stub(:body => "Lorem ipsum")
    @pl_pull_req.stub(:html_url => "http://github.com/foobar")
    @pl_pull_req.stub(:number => "123")
    @pl_pull_req.stub(:pull_request_id => "456")
    @pl_pull_req.stub(:state => "open")
    @pl_pull_req.stub(:action => "open")
    @pl_pull_req.stub(:switch_to_camel_case => lambda {})

    @pl_push = double()
    @pl_push.stub(:feed => "Github") # github
    @pl_push.stub(:type => "PushEvent") # push_event
    @pl_push.stub(:repo_name => "bitovi/canjs")
    @pl_push.stub(:head => "12345")
    @pl_push.stub(:push_id => "12345")
    @pl_push.stub(:commit_shas => ["12345","67890"])
    @pl_push.stub(:commit_shas_csv => "12345,67890")
    @pl_push.stub(:commits => [{sha: '12345', message:'first'},{sha: '67890', message:'second'}])
    @pl_push.stub(:switch_to_camel_case => lambda {})

    @pl_watch = double()
    @pl_watch.stub(:feed => "Github")
    @pl_watch.stub(:type => "Watch")
    @pl_watch.stub(:repo_name => "bitovi/canjs")
    @pl_watch.stub(:switch_to_camel_case => lambda {})    
  end

  
  context "Github" do

    context "CommitComment" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_commit_comment).procure        
          expect(entity.title).to be_a(String)
          expect(entity.body).to be_a(String)
          expect(entity.url).to be_a(String)          
          #expect(entity.props[:commit_id]).to be_a(Integer)
        end
      end      
    end

    context "IssueComment" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_issue_comment).procure        
          expect(entity.title).to be_a(String)
          expect(entity.body).to be_a(String)
          expect(entity.url).to be_a(String)          
          expect(entity.props[:repo_name]).to be_a(String)
          #expect(entity.props[:number]).to be_a(Integer)
          expect(entity.props[:label_names]).to be_a(String)
          #expect(entity.props[:comment_id]).to be_a(Integer)
        end
      end      
    end

    context "Issue" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_issue).procure        
          expect(entity.title).to be_a(String)
          expect(entity.body).to be_a(String)
          expect(entity.url).to be_a(String)          
          expect(entity.props[:repo_name]).to be_a(String)
          #expect(entity.props[:number]).to be_a(Integer)
          #expect(entity.props[:issue_id]).to be_a(Integer)
          expect(entity.props[:label_names]).to be_a(String)
          expect(entity.props[:state]).to be_a(String)
        end
      end      
    end
    
    context "PullRequest" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_pull_req).procure        
          expect(entity.title).to be_a(String)
          expect(entity.body).to be_a(String)
          expect(entity.url).to be_a(String)          
          expect(entity.props[:repo_name]).to be_a(String)
          #expect(entity.props[:number]).to be_a(Integer)
          #expect(entity.props[:pull_request_id]).to be_a(Integer)
          expect(entity.props[:state]).to be_a(String)
          expect(entity.props[:action]).to be_a(String)
        end
      end      
    end

    context "Push" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_push).procure
          expect(entity.title).to be_a(String)          
          expect(entity.url).to be_a(String)     
          expect(entity.props[:repo_name]).to be_a(String)
          expect(entity.props[:commit_shas]).to be_a(Array)
          #expect(entity.props[:push_id]).to be_a(Integer)
        end
        it "procures commits" do
          children = Entities::Procurer.new(Entity, @pl_push).procure_children
          expect(children.length).to be(2)
          # additonaly check commit attrs
        end
      end      
    end

    # context "Watch" do
    #   describe "#build" do
    #     it "instances new Entity object" do
    #       entity = Entities::Procurer.new(Entity, @pl_watch).procure        
    #       expect(entity.title).to be_a(String)          
    #     end
    #   end      
    # end

  end  
end
