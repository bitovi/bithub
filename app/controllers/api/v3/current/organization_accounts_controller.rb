class Api::V3::Current::OrganizationAccountsController < Api::V3::BaseController
  before_filter :authenticate_account!

  def index
    if !status
      @organization_accounts = current_organization.account_organizations.all
    elsif status == 'pending'
      @organization_accounts = current_organization.account_organizations.pending.all
    elsif status == 'accepted'
      @organization_accounts = current_organization.account_organizations.accepted.all
    end

    render :index
  end

  def create
    @target_account = Account.find_by_email(params[:account][:email])

    if !@target_account
      render json: { msg: 'Invitation creating failed. Non-existent user.' }, status: 404
    else
      @organization_invitation = AccountOrganization.new({
        account: target_account,
        organization: current_organization,
        invited_by_account_id: current_account.id,
        invitation_created_at: DateTime.now
      })

      if @organization_invitation.save
        Workers::DripSubscriber.perform_async @target_account.email

        @organization_accounts = current_organization.account_organizations.all
        render :index
      else
        render json: { msg: 'Invitation creating failed.' }, status: 500
      end
    end
  end

  def destroy
    AccountOrganization.find(params[:id]).destroy
  end

  def invitation_id
    params[:id]
  end

  def status
    params[:status]
  end

  def org_id
    params.require(:org_id)
  end
end

