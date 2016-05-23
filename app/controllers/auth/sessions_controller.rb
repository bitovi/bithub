class Auth::SessionsController < Devise::SessionsController

  def create
    super do |user|
      current_organization = user.organizations.first
      session['organization_id'] = current_organization.id
      session['tenant_name'] = current_organization.brands.first.tenant_name
    end
  end

  protected

  def after_sign_in_path_for(user)
    admin_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

end
