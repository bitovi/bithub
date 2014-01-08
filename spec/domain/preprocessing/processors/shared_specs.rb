shared_examples_for "every event" do

  it "should have an origin timestamp and a date" do
    expect(processed_event[:origin_ts]).to be
    expect(processed_event[:origin_date]).to be
  end

  it "should have a title" do
    expect(processed_event[:title]).to be
  end

  it "should have a source_data" do
    expect(processed_event[:source_data]).to be
  end

  it "should have a :feed in meta" do
    expect(processed_event[:meta][:feed]).to be
  end

end

shared_examples_for "an event with a body and a url" do

  it "should have a body" do
    expect(processed_event[:body]).to be
  end

  it "should have an url" do
    expect(processed_event[:url]).to be
  end

end
