class Auth::AccountRegistrationsController < Devise::RegistrationsController

  def create
    super do |account|
      plan = params.fetch(:plan)

      brand_builder = Brands::BrandBuilder.new(account, plan)
      brand_builder.build.save

      session['tenant_name'] = brand_builder.brand.tenant_name
    end
  end

  protected

  def after_sign_up_path_for(resource)
    admin_index_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_index_path
  end

end
