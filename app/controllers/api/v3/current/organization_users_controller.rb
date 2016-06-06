class Api::V3::Current::OrganizationUsersController < Api::V3::ApiController

  def index
    if !status
      @organization_users = current_organization.user_organizations.all
    elsif status == 'pending'
      @organization_users = current_organization.user_organizations.pending.all
    elsif status == 'accepted'
      @organization_users = current_organization.user_organizations.accepted.all
    end

    render :index
  end

  def create
    @target_user = User.find_by_email(params[:user][:email])

    if @target_user.blank?
      render json: { msg: 'Invitation creating failed. Non-existent user.' }, status: 404
    else
      @organization_invitation = UserOrganization.new({
        user: @target_user,
        organization: current_organization,
        invited_by_user_id: current_user.id,
        invitation_created_at: DateTime.now
      })

      if @organization_invitation.save
        CreateDripSubscriberJob.perform_later @target_user.email
        render :show
      else
        render json: { msg: 'Invitation creation failed.' }, status: 406
      end
    end
  end

  def destroy
    UserOrganization.find(params[:id]).destroy
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

