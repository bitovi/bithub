# require 'domain/spec_helper'

# describe Accounts::AccountLinker do
  
#   describe "#update_blank_oauth_attrs" do
#     it "should update the user's attrs if they're blank" do
#       user = create(:user, name: "Nikica Jokic", email: nil)
#       user.update_blank_oauth_attrs!({name: "Nikica Prdovic", email: "neektza@gmail.com"})
#       expect(user.reload.email).to eq ("neektza@gmail.com")
#     end
#   end

#   describe "#link_ident!" do

#     before :each do
#       @nikica = create(:user, name: 'Nikica', email: 'neektza@gmail.com')
#       @veljko = create(:user, name: 'Veljko', email: 'veljko@kset.org')
#     end

#     context "when there is already a github identity associated with the user" do
#       it "should add a new twitter identity to the existing user" do
#         identity_github = create(:identity, uid: 987654321, provider: 'github', user: @nikica)
#         identity_twitter = create(:identity, uid: 123456789, provider: 'twitter')

#         @nikica.link_ident!(identity_twitter)
#         expect(@nikica.reload.identities.where({:provider => 'twitter'}).first).to be
#       end
#     end

#     context "when there is already a twitter identity associated with the user" do
#       it "shoul add a new twitter identity to the existing user" do
#         identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: @nikica)
#         identity_github = create(:identity, uid: 987654321, provider: 'github')

#         @nikica.link_ident!(identity_github)
#         expect(@nikica.reload.identities.where({:provider => 'github'}).first).to be
#       end
#     end

#     context "when there is already another user that owns the identity being merged" do
#       it "should destroy the other user and snatches it's identity" do
#         identity_github = create(:identity, uid: 987654321, provider: 'github', user: @nikica)
#         identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: @veljko)
#         @nikica.link_ident!(identity_twitter)
#         expect(User.where(:id => @veljko).first).to be_nil
#       end
#     end
#   end
# end
