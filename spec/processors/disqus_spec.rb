require 'spec_helper'
require 'app/processor'

describe Processor do
  describe "#process" do

    context "when processing Disqus comments" do
      let(:processed_event) { load_and_process('comment_list') }

      def load_and_process(event_type)
        resp = Response.load('disqus', event_type)
        Processor.new('disqus').process(resp["response"])
      end

      it_should_behave_like "every event"
      it_should_behave_like "an event with a body and a url"

      it "should have :origin_author name in :meta" do
        expect(processed_event[:meta][:origin_author_name]).to be
      end
    end
  end
end
