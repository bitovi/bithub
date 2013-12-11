require 'spec_helper'
require 'app/processor'

describe Processor do
  describe "#process" do

    context "when processing Blog posts" do
      let(:processed_event) { load_and_process('posts') }

      def load_and_process(event_type)
        resp = Response.load('blog', event_type)['rss']['channel']['item'][0]
        Processor.new('blog').process(resp)
      end

      it_should_behave_like "every event"
      it_should_behave_like "an event with a body and a url"
    end
  end
end
