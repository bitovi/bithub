class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]

  def create
    super do |account|
      plan_name = params.fetch(:plan)
      plan = Plan.find_by_stripe_id plan_name

      org_builder = Organizations::OrganizationBuilder.new(account, plan)
      org_builder.build.save!

      # TODO: handle multiple brands on organization
      session['tenant_name'] = org_builder.brands.first.tenant_name
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :invite_key
  end

  def after_sign_up_path_for(account)
    current_api_v3_accounts_path
  end

  def after_inactive_sign_up_path_for(account)
    current_api_v3_accounts_path
  end

end
