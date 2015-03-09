class Auth::AccountRegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def create
    super do |account|
      plan_name = params.fetch(:plan)
      plan = Plan.find_by_stripe_id plan_name

      # TODO: validate plan

      org_builder = Organizations::OrganizationBuilder.new(account, plan)
      org_builder.build.save!

      # TODO: handle multiple brands on organization
      session['tenant_name'] = org_builder.brand.tenant_name
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
    devise_parameter_sanitizer.for(:sign_up) << :invite_key
  end

  def after_sign_up_path_for(resource)
    admin_index_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_index_path
  end
end
