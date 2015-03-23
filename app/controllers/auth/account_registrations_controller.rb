class Auth::AccountRegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?

  PROMO_CODE = 'ymip412'

  def new
    @plan = find_plan
    super
  end

  def create
    @plan = find_plan

    @invite_code = InviteCode.where(code: PROMO_CODE).first
    ActiveRecord::Base.transaction do
      super do |account|
        if account.invite_code_valid?
          account.invite_code.use_up_if_useable

          org_builder = Organizations::OrganizationBuilder.new(account, @plan)
          org_builder.build.save!

          # TODO: handle multiple brands on organization
          session['tenant_name'] = org_builder.brand.tenant_name
        end
      end
    end
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

  def find_plan
    plan_name = params[:plan]

    if plan = Plan.find_by_stripe_id(plan_name)
      plan
    else
      Plan.find_by_name('startup') || Plan.first
    end
  end
end
