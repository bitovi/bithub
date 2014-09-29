RSpec.describe Solipsism, :type => :lib do

    class Filter < ActiveRecord::Base
      include Solipsism
    end

    describe ".has_an_attribute?" do
      context "symbol given" do
        it "confirms that the Entity model indeed has an attribute" do
          expect(Filter.has_an_attribute?(:category)).to be_truthy
        end

        it "denies that the Entity model has a non-existent attribute" do
          expect(Filter.has_an_attribute?(:budalas)).to be_falsey
        end
      end

      context "string given" do
        it "confirms that the Entity model indeed has an attribute" do
          expect(Filter.has_an_attribute?("title")).to be_truthy
        end

        it "denies that the Entity model has a non-existent attribute" do
          expect(Filter.has_an_attribute?("tite")).to be_falsey
        end
      end
    end
  
end
