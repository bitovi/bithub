require 'spec_helper'
require 'digest/md5'
require 'responses/responses'

describe Processor do

  describe "#process" do
    before :all do
      event_hash = Response.load('blog', 'post')
      @processed_event = Processor.new('blog').process(event_hash)
    end

    it_should_behave_like "every event"
    it_should_behave_like "an event with a body and a url"

    it "should have an :origin_author_name in meta" do
      expect(@processed_event[:meta][:origin_author_name]).to be
    end
  end

  describe "#disqus" do
    before :all do
      @event = Response.load('disqus', 'comment')
      @processed_event = Processor.new('disqus').process(event_hash)
    end
  end

  describe "#forums" do
    before :all do
      @event = Response.load('forums', 'post')
      @processed_event = Processor.new('blog').process(event_hash)
      end
    end
  end

  describe "#github" do
  end

  describe "#twitter" do
  end


end
