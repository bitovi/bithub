require 'spec_helper'
require 'digest/md5'

describe Handler::Github do

  context "upon fetching Github event" do

    describe "#prepare_event" do
      it "parses timestamp"
      it "plucks out some source_data attributes to meta hash"
      it "generates unique hash key"
    end

  end

end
