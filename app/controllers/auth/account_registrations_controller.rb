class Auth::AccountRegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?
  
  POSSIBLE_PLANS = %w(startup)

  def new
    @plan_name = plan_name
    super
  end

  def create
    super do |account|
      brand_builder = Brands::BrandBuilder.new(account, plan_name)
      brand_builder.build.save

      session['tenant_name'] = brand_builder.brand.tenant_name
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :invite_key
  end

  def after_sign_up_path_for(resource)
    admin_index_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_index_path
  end

  def plan_name
    unless POSSIBLE_PLANS.include?(params[:plan])
      "startup"
    else
      params[:plan]
    end
  end
end
