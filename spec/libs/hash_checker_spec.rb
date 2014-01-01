require 'spec_helper'

describe HashChecker do

  describe "#verify" do

    before :all do
      @definitions = {
        [:foo, :bar] => String,
        [:foo, :baz] => Integer,
        [:foo, :baz] => Proc.new {|x| x % 2 == 0},
        [:bazz] => nil
      }
      @target = {
        foo: {
          bar: "lorem ipsum ...",
          baz: 10
        },
        bazz: nil
      }
    end
    
    it "iterates through definitions and examines the target hash" do
      expect(HashChecker::verify(@definitions, @target)).to eq(true)      
    end    
  end

  describe "#verify_def" do 
    it "compares given check and fetched value from hash" do      
      expect(HashChecker::verify_def(Integer, 10)).to eq(true)
      expect(HashChecker::verify_def(String, "foo")).to eq(true)
      expect(HashChecker::verify_def(Integer, "foo")).to eq(false)
      expect(HashChecker::verify_def(Proc.new {|x| x % 2 == 0}, 10)).to eq(true)             
    end
  end

  describe "#walk_path" do 
    it "iterates over array of attributes and returns last value" do
      hash = {foo: {bar: "baz"}}
      
      expect(HashChecker::walk_path([:foo, :bar], hash)).to eq("baz")
      expect(HashChecker::walk_path(['foo', 'bar'], hash)).to eq("baz")
      expect(HashChecker::walk_path('foo.bar', hash)).to eq("baz")
      expect(HashChecker::walk_path([:foo, :bar, :baz], hash)).to eq(false)
    end
  end
  
end
