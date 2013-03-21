class Api::UsersController < ApplicationController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    Rails.logger.info muster_query

    @users = Users.all
    render :index
  end

  def show
    @event = User.find(params[:id])
    render :show
  end

  def activities
    render :json => User.find(params[:id]).activities.to_json
  end

end
