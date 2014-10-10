class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController
  def create
    super do |acc|
      Brands::BrandBuilder.new(acc).build.save
    end
  end

  protected

  def after_sign_up_path_for(resource)
    subdomain = resource.brand.tenant_name
    "http://#{subdomain}.#{request.domain}/admin"
  end

  def after_inactive_sign_up_path_for(resource)
    '/admin'
  end
end
