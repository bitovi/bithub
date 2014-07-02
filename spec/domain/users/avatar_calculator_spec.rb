RSpec.describe Users::AvatarCalculator, :type => :domain do

  describe "#maybe_source_data" do
    it "should be able to get the avatar url from identity's source data"
    it "should be able to get the avatar url from the Gravatar service"
    it "should default to a default image if there are no other sources"
    it "should first try the Gravatar service, then source data and finally default image"
  end

end
