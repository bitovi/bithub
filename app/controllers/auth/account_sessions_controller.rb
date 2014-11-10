class Auth::AccountSessionsController < Devise::SessionsController

  protected

  def after_sign_in_path_for(account)
    # find brand, if there is more than one display options
    if account.brands.count == 1
      session['tenant_name'] = account.brands.first.tenant_name

      admin_index_path
    else
      choose_brand_admin_index_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_account_session_path
  end

end
