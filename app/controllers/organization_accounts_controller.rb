class OrganizationAccountsController < ApplicationController

  before_filter :authenticate_account!
  layout 'backend_admin'

  def index
    # authorize!(:manage, Organization)
    @members = current_organization.account_organizations.where.not(invitation_accepted_at: nil).map(&:account)
    render :index
  end

  def choices
    if current_account.account_organizations.where.not(invitation_accepted_at: nil).count == 1
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
