class OrganizationAccountsController < ApplicationController

  before_filter :authenticate_account!
  layout 'backend_admin'

  def choices
    if current_account.organizations.count == 1
      session['organization_name'] = current_account.organizations.first.name
      redirect_to choices_brand_path
    else
      @organizations = current_account.organizations
      render :choices
    end
  end

  def choose
    if org = current_account.organizations.find(org_id)
      session['organization_name'] = org.name
      redirect_to choices_brand_path
    else
      render text: 'error'
    end
  end

  def org_id
    params.require(:org_id)
  end
end
