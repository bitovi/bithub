class Auth::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def create
    ActiveRecord::Base.transaction do
      super do |account|
        org_builder = Organizations::OrganizationBuilder.new account, params

        begin
          ActiveRecord::Base.transaction do
            org_builder.build.save!
          end

        rescue ActiveRecord::RecordInvalid => e
          # swallow exception on account validation
          # errors will be displayed on register form
        end

        Workers::DripSubscriber.perform_async account.email

        # TODO: handle multiple brands on organization
        session['organization_id'] = org_builder.organization.id
        session['tenant_name'] = org_builder.brand.tenant_name
      end
    end

  rescue Organizations::OrganizationBuilder::BuildingError => e
    render :new
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:name)
    devise_parameter_sanitizer.for(:account_update).push(:name)
    devise_parameter_sanitizer.for(:invite).push(:name)
    devise_parameter_sanitizer.for(:accept_invitation).push(:name)
  end

  def after_sign_up_path_for(resource)
    admin_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_path
  end
end
