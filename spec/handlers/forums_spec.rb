require 'spec_helper'
require 'digest/md5'
require 'responses/responses.rb'

describe Handler::Forums do

  context "upon fetching Forums event" do

    describe "#prepare_event" do
      before do
        @event = Response.load('forums', 'post')
        @prepared = Handler::Forums.prepare_event(@event, {:feed => 'forums'})
      end

      it_should_behave_like "every event"

      it "has body and url" do
        expect(@prepared[:body]).to be
        expect(@prepared[:url]).to be
      end

      it "has some meta props" do
        expect(@prepared[:meta][:origin_author_name]).to be
        #expect(@prepared[:meta][:type]).to be
        #expect(@prepared[:meta][:category]).to be
      end
    end
    
  end
end
