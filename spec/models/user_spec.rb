require 'spec_helper'

describe User do
  describe "#sum_points" do
    it "calculates total points" do
      user = create(@user)
      expect(user.sum_points).to eq(sum)
    end
  end

end
