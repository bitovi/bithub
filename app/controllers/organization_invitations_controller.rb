class OrganizationInvitationsController < ApplicationController

  before_filter :authenticate_account!
  layout 'backend_admin'

  def index
    if !status || status == 'pending'
      @invitations = AccountOrganization.where(organization: current_organization, account: current_account, invitation_accepted_at: nil).all
    elsif status == 'accepted'
      @invitations = AccountOrganization.where(organization: current_organization, account: current_account).not(invitation_accepted_at: nil).all
    end

    render :index
  end

  def new
    @invitation = AccountOrganization.new(organization: current_organization)
    render :new
  end

  def update
    if @invitation = AccountOrganization.find_by_id(invitation_id)
      if @invitation.confirm!
        redirect_to choices_organization_path
      else
        flash[:error] = 'Invitation confirmation failed.'
        redirect_to organization_invitations_path
      end
    end
  end

  def create
    if target_account = Account.find_by_email(params[:account][:email])

      @invitation = AccountOrganization.new({
        account: target_account,
        organization: current_organization,
        invited_by_account_id: current_account.id,
        invitation_created_at: DateTime.now
      })

      if @invitation.save
        flash[:info] = 'Invitation created.'
        redirect_to organization_accounts_path
      else
        flash[:error] = 'Invitation creation failed.'
        redirect_to new_organization_invitation_path
      end
    else
      flash[:error] = 'Non-existent user.'
      redirect_to new_organization_invitation_path
    end
  end

  def invitation_id
    params[:id]
  end

  def status
    params[:status]
  end
end
