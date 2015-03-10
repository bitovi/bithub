class Auth::AccountRegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?
  
  POSSIBLE_PLANS = %w(startup)
  DEFAULT_PLAN = "startup"

  def new
    @plan_name = plan_name
    super
  end

  def create
    @plan_name = plan_name
    super do |account|
      if account.invite_code_valid?
        account.invite_code.use_up_if_useable
        brand_builder = Brands::BrandBuilder.new(account, @plan_name)
        brand_builder.build.save

        session['tenant_name'] = brand_builder.brand.tenant_name
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :code
  end

  def after_sign_up_path_for(resource)
    admin_index_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_index_path
  end

  def plan_name
    unless POSSIBLE_PLANS.include?(params[:plan])
      DEFAULT_PLAN
    else
      params[:plan] || DEFAULT_PLAN
    end
  end
end
