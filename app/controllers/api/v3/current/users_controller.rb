class Api::V3::Current::UsersController < Api::V3::Current::AbstractController
  represents_resource User

  def update
    @user = current_user
    authorize! :update, @user

    if params[:user].keys.grep(/password/).count > 0
      if @user.update_with_password(resource_params)
        sign_in(@user, :bypass => true)
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors }, status: :not_acceptable
      end
    else
      if @user.update(resource_params)
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors }, status: :not_acceptable
      end
    end
  end

  private
  def resource_params
    params.require(:user).permit(:name, :password, :password_confirmation, :current_password)
  end
end
