class Api::V3::Current::AccountsController < Api::V3::Current::AbstractController
  represents_resource Account


  def update
    @account = current_account
    authorize! :update, @account

    if params[:account].grep(/password/).count > 0
      if @account.update_with_password(resource_params)
        sign_in(@account, :bypass => true)
        render json: @account, status: :ok
      else
        render json: { errors: @account.errors }, status: :not_acceptable
      end
    else
      if @account.update(resource_params)
        render json: @account, status: :ok
      else
        render json: { errors: @account.errors }, status: :not_acceptable
      end
    end
  end

  private
  def resource_params
    params.require(:account).permit(:name, :password, :password_confirmation, :current_password)
  end
end
