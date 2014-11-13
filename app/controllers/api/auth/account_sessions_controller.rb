class Api::Auth::AccountSessionsController < Devise::SessionsController
  before_filter :configure_sign_in_params, only: [:create]

  def create
    super do |account|

      # log user into brand
      if account.brands.count == 1
        session['tenant_name'] = account.brands.first.tenant_name
      end

    end
  end

  def destroy
    super do
      render :json => { :msg => 'Session destroyed'}, :status => 200 and return
    end
  end

  def failure
    render :json => { :msg => "Invalid login" }, :status => 401
  end

  protected

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#failure" }
  end

  # also the case when user is already logged in
  def after_sign_in_path_for(account)
    current_api_v3_accounts_path
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << :brand
  end
end
