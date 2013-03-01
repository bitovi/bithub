require 'spec_helper'

describe User do
  describe "#login_via_oauth" do
    context "when there is no user in the system" do
      it "creates the user instance"
    end

    context "when the user is already in the system" do
      it "just logs in the user"
    end
  end
end
