class Auth::InvitationsController < Devise::InvitationsController
  before_filter :authenticate_account!

  def create
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    resource.account_organizations.create(
      organization: current_organization,
      invitation_created_at: DateTime.now,
      invitation_accepted_at: DateTime.now
    )

    if resource_invited
      render json: resource
    else
      render json: { msg: 'Invitation failed' }, status: 400
    end
  end

  def update
    super do |account|
      account.name = params[:account][:name] if params[:account][:name]
      session['organization_id'] = account.organizations.first.id
      session['tenant_name'] = account.organizations.first.brands.first.tenant_name
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:invite).push(:name)
    devise_parameter_sanitizer.for(:accept_invitation).push(:name)
  end

  def after_accept_path_for(account)
    admin_path
  end

  def current_organization
    Organization.find(session['organization_id'])
  end
end
