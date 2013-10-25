require 'spec_helper'
require 'spec/processors/shared_specs'
require 'responses/responses'

require 'app/processor'

describe Processor do
  describe "#process" do

    context "when processing forum posts" do
      let(:processed_event) { load_and_process('post') }
      
      def load_and_process(event_type)
        resp = Response.load('forums', event_type)
        Processor.new('forums').process(resp)
      end

      it_should_behave_like "every event"
      it_should_behave_like "an event with a body and a url"

      it "should have :origin_author name in :meta" do
        expect(processed_event[:meta][:origin_author_name]).to be
      end
    end
  end
end
