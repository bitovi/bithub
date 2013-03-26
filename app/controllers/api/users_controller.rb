class Api::UsersController < ApplicationController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    Rails.logger.info muster_query

    @users = User.all
    render :index
  end

  def show
    @user = User.find(params[:id])
    render :show
  end
end
