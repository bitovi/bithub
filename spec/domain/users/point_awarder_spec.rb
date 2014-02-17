describe Users::PointAwarder do

  describe "#already_awarded_for_profile_completion" do
    it "should return true if the user has already been awarded" do
      @user = create(:user)
      expect(@user.already_awarded_for_profile_completion?).to eql false
    end
    
    it "should return false if the user hasn't already been awarded" do
      @user = create(:user)
      Internal.create!({receiver: @user, value: 1, comment: "Completed profile."})
      expect(@user.already_awarded_for_profile_completion?).to eql true
    end
  end

  describe "#check_and_award_points_for_completing_profile" do
    it "should award +1 point for competing profile" do
      @user = create(:user)
      @user.stub(:completed_profile?).and_return(true)
      @user.check_and_award_points_for_completing_profile
      expect(@user.score).to eq 1
    end
  end
  
  describe "#award_points_for_linking" do
    it "should award +1 point for singning in with twitter/github for the first time" do
      @user = create(:user)
      @user.award_points_for_linking('twitter').save!
      expect(@user.reload.score).to eq 1
    end
  end
  
  describe "#completed_profile?" do
    it "should return false if user's profile has not been completed" do
      user = build(:user, name: "Mali")
      expect(user.completed_profile?).to eq false
    end
    
    it "should return true if user's profile has been completed" do
      user = build(:user,
        name: "Mali",
        email: "mali@mail.com",
        address: "Ajme",
        city: "Moram",
        postal: "Pisat",
        country: Country.new(name: "Ove gluposti")
      )

      expect(user.completed_profile?).to eq true
    end
  end


end
