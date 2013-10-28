require 'spec_helper'
require 'digest/md5'

describe Handler do

  describe "#reject_old" do
    before :each do
      @logger = double(); @exchange = double()
      @endpoint = 'https://api.example.com/entities'
      @h = Handler.new(@logger, @exchange, @endpoint) {|c| c.backlog_size = 10}
    end

    it "should have a backlog of 10 items at most" do
      items = (1..13).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      @h.reject_old(items)

      expect(@h.latest.length).to eql 10
    end

    it "should reject items with the same hash key" do
      items = (1..5).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      new_items = (1..5).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }

      @h.reject_old(new_items)
      @h.latest =~ items
    end

    it "should append items when there are no overlaps" do
      items = (1..4).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      new_items = (5..8).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }

      @h.reject_old(new_items)
      @h.latest =~ (items + new_items)
    end

    it "should push out old items when new ones come in and the array is full" do
      items = (1..7).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
      new_items = (8..11).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }

      @h.reject_old(new_items)
      @h.latest =~ (4..11).map {|i| {title: i.to_s, hash_key: Digest::MD5.hexdigest(i.to_s)} }
    end
  end

end

  # describe "#fetch" do
  #   before :each do
  #     @logger = double(); @exchange = double()
  #     @logger.stub(:error) { nil }
  #     @endpoint = 'https://api.example.com/resource'
  #     @h = Handler.new(@logger, @exchange, @endpoint)
  #   end

  #   it "suceeds when it gets 200 back" do
  #     stub_request(:get, 'https://api.example.com/resource')
  #       .to_return(:body => "Something", :status => 200)

  #     EM.run_block { @h.fetch }
  #   end

  #   it "fails when it gets 4xx back" do
  #     stub_request(:get, 'https://api.example.com/resource')
  #       .to_return(:body => "Client error", :status => 400)

  #     expect(@h.fetch).to raise_error FetchFailedException
  #   end
    
  #   it "fails when it gets 5xx back" do
  #     stub_request(:get, 'https://api.example.com/resource')
  #       .to_return(:body => "Server error", :status => 500)

  #     expect(@h.fetch).to raise_error FetchFailedException
  #   end
  # end
