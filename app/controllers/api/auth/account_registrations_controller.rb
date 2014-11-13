class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]

  def create
    super do |account|
      plan = params.fetch(:plan)

      brand_builder = Brands::BrandBuilder.new(account, plan)
      brand_builder.build.save

      session['tenant_name'] = brand_builder.brand.tenant_name
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :plan
  end

  def after_sign_up_path_for(account)
    current_api_v3_accounts_path
  end

  def after_inactive_sign_up_path_for(account)
    current_api_v3_accounts_path
  end

end
