class Auth::InvitationsController < Devise::InvitationsController
  before_filter :authenticate_account!

  def create
    super do |account|
      account.account_organizations.create(
        organization: current_organization,
        invitation_created_at: DateTime.now,
        invitation_accepted_at: DateTime.now
      )
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:invite).push(:name)
    devise_parameter_sanitizer.for(:accept_invitation).push(:name)
  end

  def after_accept_path_for(account)
    choices_organization_path
  end

  def current_organization
    Organization.find(session['organization_id'])
  end
end
