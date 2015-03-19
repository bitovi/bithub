class Auth::AccountSessionsController < Devise::SessionsController

  protected

  def after_sign_in_path_for(account)
    # TODO: choose organization and choose brand
    session['tenant_name'] = account.organizations.first.brands.first.tenant_name

    admin_index_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_account_session_path
  end

end
