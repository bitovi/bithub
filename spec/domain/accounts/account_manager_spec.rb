describe Accounts::AccountManager, :type => :domain do

  describe "#linking_or_merging?" do
    it "determines if we're linking or merging identities/users"
  end
  
  describe "#only_logging_in?" do
    it "determines wheteher we're only logging (ie. not doing something more complex)"
  end
  
  describe "#procure" do
    context "when user is already logged_in (current_user exists)" do
      it "just returns the current_user"
    end

    context "when user isn't logged in, but exists in the system" do
      it "looks up the user in the provided identity"
    end

    context "when the user doesn't exist" do
      it "delegates creation of the user to AccountCreator"
    end
  end

  describe "#link_and_merge" do
    it "delegates linking or merging of identities/users to AccountLinker"
  end

end
