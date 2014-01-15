require 'domain/entities/spec_helper'

describe Entities::Procurer do

  before :each do
    @pl_post = double()
    @pl_post.stub(:feed => "Forum")
    @pl_post.stub(:type => "Post")
    @pl_post.stub(:title => "Some title")
    @pl_post.stub(:body => "Lorem ipsum")
    @pl_post.stub(:link => "http://forums.com/foobar")
    @pl_post.stub(:subforum => "questions")
    @pl_post.stub(:origin_author_name => "random user")
  end

  
  context "Forum" do

    context "Post" do
      describe "#build" do
        it "instances new Entity object" do
          entity = Entities::Procurer.new(Entity, @pl_post).procure        
          expect(entity.title).to be_a(String)
          expect(entity.body).to be_a(String)
          expect(entity.url).to be_a(String)          
          expect(entity.props[:origin_author_name]).to be_a(String)
          expect(entity.props[:tags]).to eq(['questions'])
       end
      end      
    end

  end  
end
