require 'no_rails_spec_helper'
require 'services/crawler/crawler'

describe Configurator do

  before :each do
    Celluloid.shutdown
    Celluloid.boot
  end

  describe "#all_brands" do
    it "should fetch all feed configs from the web component" do
      VCR.use_cassette('crawler_config') do
        c = Configurator.new :environment => 'development'
        expect(c.all_brands).not_to be_nil
        expect(c.all_brands).not_to be_empty
      end
    end
  end

  describe "brand" do
    it "fetches config for a brand (all feeds)" do
      VCR.use_cassette('crawler_config') do
        c = Configurator.new :environment => 'development'
        expect(c.brand(:neektza)).not_to be_nil
        expect(c.brand(:neektza)).not_to be_empty
      end
    end
  end
  
  describe "feed" do
    it "fetches config for a brand's feed" do
      VCR.use_cassette('crawler_config') do
        c = Configurator.new :environment => 'development'
        expect(c.feed(:neektza, :facebook)).not_to be_nil
        expect(c.feed(:neektza, :facebook)).not_to be_empty
      end
    end
  end
end
