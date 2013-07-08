require 'spec_helper'
require 'digest/md5'
require 'responses/responses.rb'

shared_examples_for "every event" do
  it "has title" do
    expect(@prepared[:title]).to be
  end
  
  it "parses timestamp" do
    expect(@prepared[:origin_ts]).to be
    expect(@prepared[:origin_date]).to be
  end
  
  it "has source data" do
    expect(@prepared[:source_data]).to be
  end
  
  it "has feed in meta" do
    expect(@prepared[:meta]).to be
    expect(@prepared[:meta][:feed]).to be
  end
end
