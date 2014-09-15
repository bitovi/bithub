require 'uri'
require 'domain/spec_helper'

RSpec.describe Users::AvatarCalculator, :type => :domain do

  describe "#maybe_gravatar" do
    it "should be able to get the avatar url from the Gravatar service" do

      @user_with_email = FactoryGirl.create(:user)
      avatar_url = Users::AvatarCalculator.new(@user_with_email).maybe_gravatar

      expect(avatar_url).to eq("http://gravatar.com/avatar/#{Digest::MD5.hexdigest(@user_with_email.email)}")
    end
  end

  describe "#maybe_source_data" do
    it "tries to get avatar url from identity's source data" do
      @user_with_idents = FactoryGirl.create(:user, :without_email, :identities => [
        (@gh_ident = FactoryGirl.create(:identity,
                                        :provider => 'github',
                                        :source_data => { :avatar_url => 'https://octodex.github.com/images/dunetocat.png' })),
        (@tw_ident = FactoryGirl.create(:identity,
                                        :provider => 'twitter',
                                        :source_data => { :profile_image_url => 'https://twitter.com/res/some_image.jpg' }))
      ])

      avatar_url = Users::AvatarCalculator.new(@user_with_idents).calculate
      expect(avatar_url).to eq(@gh_ident.source_data['avatar_url'])
    end
  end

  describe "#calculate" do
    it "defaults with a default image if it can't find an image in other sources" do
      @user_without_valid_idents = FactoryGirl.create(:user, :without_email)
      avatar_url = Users::AvatarCalculator.new(@user_without_valid_idents).calculate
      expect(avatar_url).to eq('/assets/images/icon-user.png')
    end
  end
end
