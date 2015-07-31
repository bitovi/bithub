class BrandAccountsController < ApplicationController

  before_filter :authenticate_account!
  layout 'backend_admin'

  def choices
    if current_organization.brands.count == 1
      session['tenant_name'] = current_organization.brands.first.tenant_name
      redirect_to admin_path
    else
      @brands = current_organization.brands
      render :choices
    end
  end
  
  def choose
    if brand = current_organization.brands.find(brand_id)
      session['tenant_name'] = brand.tenant_name
      redirect_to admin_path
    else
      render text: 'error'
    end
  end

  def brand_id
    params.require('brand_id')
  end
end
