class Api::V3::Current::AccountOrganizationsController < Api::V3::BaseController
  represented_resource Account

  def index
    if !status
      @account_organizations = current_account.account_organizations.all
    elsif status == 'pending'
      @account_organizations = current_account.account_organizations.pending.all
    end

    render :index
  end

  def update
    @account_organization = current_account.account_organizations.find(invitation_id)

    if @account_organization.confirm!
      render json: { msg: 'Invitation confirmed.' }
    else
      render json: { msg: 'Invitation confirmation failed.' }, status: 500
    end
  end

  private
  def invitation_id
    params[:id]
  end
end
