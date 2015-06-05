class Auth::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def new
    @plan = find_plan
    super
  end

  def create
    @plan = find_plan
    ActiveRecord::Base.transaction do
      super do |account|
        org_builder = Organizations::OrganizationBuilder.new(account, @plan)

        begin
          org_builder.build.save!
        rescue ActiveRecord::RecordInvalid => e
          # catch exception on account validation
          # errors will be displayed on register form
        end

        Workers::DripSubscriber.perform_async account.email

        # TODO: handle multiple brands on organization
        session['organization_name'] = org_builder.organization.name
        session['tenant_name'] = org_builder.brand.tenant_name
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:name)
  end

  def after_sign_up_path_for(resource)
    admin_index_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_index_path
  end

  def find_plan
    if plan_name
      Plan.find_by_stripe_id(plan_name)
    else
      Plan.find_by_stripe_id('startup')
    end
  end

  def plan_name
    params[:plan]
  end
end
