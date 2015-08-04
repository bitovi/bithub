class Auth::SessionsController < Devise::SessionsController

  protected

  def after_sign_in_path_for(account)
    admin_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_account_session_path
  end

end
