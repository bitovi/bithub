class Api::V3::AccountsController < Api::V3::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def current
    if @account = current_account
      render :show
    else
      render json: msg_hash(@brand, 'update'), status: 406
    end
  end

end
