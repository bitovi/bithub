class Api::Auth::AccountSessionsController < Devise::SessionsController

  def after_sign_in_path_for(resource)
    '/admin'
  end

  def after_sign_out_path_for(resource_or_scope)
    '/login'
  end
end
