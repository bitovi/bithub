class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController

  def create
    super do |account|
      brand_builder = Brands::BrandBuilder.new(account)
      brand_builder.build.save

      session['tenant_name'] = brand_builder.brand.tenant_name
    end
  end

  protected

  def after_sign_up_path_for(resource)
    admin_path
  end

  def after_inactive_sign_up_path_for(resource)
    admin_path
  end

end
