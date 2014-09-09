require 'domain/spec_helper'

RSpec.describe Users::Snatcher, :type => :domain do

  before do
    @veljko = create(:user, name: 'Veljko')
    @nikica = create(:user, name: 'Nikica')
  end

  subject(:snatcher) { Users::Snatcher.new(@nikica, @veljko) }

  describe "#snatch_entities" do
    it "snatches entities from other user"
  end

  describe "#snatch_actions" do
    it "snatches activities in which the user is an actor from other user"
  end

  describe "#snatch_internals" do
    it "snatches internals from other user"
  end
end
