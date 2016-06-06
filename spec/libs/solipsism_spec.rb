require 'rails_helper'

RSpec.describe Solipsism, :type => :lib do

    class Filter < ActiveRecord::Base
      extend Solipsism
    end

    describe ".has_an_attribute?" do
      context "symbol given" do
        it "confirms that the Bit model indeed has an attribute" do
          expect(Filter.has_an_attribute?(:action)).to be_truthy
        end

        it "denies that the Bit model has a non-existent attribute" do
          expect(Filter.has_an_attribute?(:budalas)).to be_falsey
        end
      end

      context "string given" do
        it "confirms that the Bit model indeed has an attribute" do
          expect(Filter.has_an_attribute?("action")).to be_truthy
        end

        it "denies that the Bit model has a non-existent attribute" do
          expect(Filter.has_an_attribute?("titey")).to be_falsey
        end
      end
    end

end
