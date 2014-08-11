require 'celluloid/test'
require 'spec_helper'
require 'services/crawler/configurator'

describe Configurator do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  describe "#static_config" do
    it "reads config from ENV"
  end

  describe "#all_brands" do
    it "fetches all feed configs from the web component"
  end

  describe "brand" do
    it "filters by brand from data fetched by #all_brands"
  end

  describe "feed" do
    it "filters by brand and feed from data fetched by #all_brands"
  end
end
