require 'celluloid/test'
require 'spec_helper'
require 'services/crawler/configurator'

describe Configurator do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  describe "#config_file_path" do
    it "tells the Configurator where to look for static config file" do
      expect(Configurator.new(:environment => 'development').config_file_path).to\
        eq File.expand_path('config/services/crawler/development.yml')
    end
  end

  describe "#all_brands" do
    it "should fetch all feed configs from the web component"
  end

  describe "brand" do
    it "fetches config for a brand (all feeds)"
  end

  describe "feed" do
    it "fetches config for a brand's feed"
  end
end
