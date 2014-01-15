require 'domain/entities/spec_helper'

describe Entities::Procurer do

  before :each do
    @pl_status = double()
    @pl_status.stub(:feed => "Twitter")
    @pl_status.stub(:type => "Tweet")
    @pl_status.stub(:tweet_id => "1234567")
    @pl_status.stub(:text => "160 character tweet text")
    @pl_status.stub(:html_url => "http://twitter.com/foobar")
    @pl_status.stub(:origin_author_id => "123")
    @pl_status.stub(:origin_author_name => "canjs")
    @pl_status.stub(:retweeted_id => nil)
    @pl_status.stub(:retweet? => false)
  end

  before :each do
    @pl_follow = double()
    @pl_follow.stub(:feed => "Twitter")
    @pl_follow.stub(:type => "Follow")
    @pl_follow.stub(:source_id => "123")
    @pl_follow.stub(:source_screen_name => "foobar")
    @pl_follow.stub(:target_screen_name => "canjs")
  end
  
  context "Twitter" do

    context "Tweet" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_status).procure        
          expect(entity.title).to be_a(String)
          expect(entity.url).to be_a(String)          
          expect(entity.props[:origin_author_id]).to be_a(String)
          expect(entity.props[:origin_author_name]).to be_a(String)
        end
      end      
    end

    context "Follow" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_follow).procure        
          expect(entity.title).to be_a(String)
          expect(entity.props[:origin_author_id]).to be_a(String)
          expect(entity.props[:origin_author_name]).to be_a(String)
        end
      end      
    end

  end  
end
