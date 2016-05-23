class Api::V3::Current::UserOrganizationsController < Api::V3::ApiController
  def index
    if !status
      @user_organizations = current_user.user_organizations.all
    elsif status == 'pending'
      @user_organizations = current_user.user_organizations.pending.all
    end

    render :index
  end

  def update
    @user_organization = current_user.user_organizations.find(invitation_id)

    if @user_organization.confirm!
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
