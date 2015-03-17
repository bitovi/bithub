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

        plan_name = params.fetch(:plan)
        plan = Plan.find_by_stripe_id plan_name

        # TODO: validate plan
        org_builder = Organizations::OrganizationBuilder.new(account, plan)
        org_builder.build.save!

        # TODO: handle multiple brands on organization
        session['tenant_name'] = org_builder.brand.tenant_name
      end
    end
  end

  def new
    plan_name = params.fetch(:plan)
    plan = Plan.find_by_stripe_id plan_name

    raise ActionController::RoutingError.new('Not Found') unless plan

    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:name, :code)
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
