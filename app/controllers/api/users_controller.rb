class Api::UsersController < ApplicationController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors


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

  def activities
    @activities = ActivityDecorator.decorate_collection(User.find(params[:user_id]).activities)
    render 'api/activities/index'
  end

  def events
    @events = EventDecorator.decorate_collection(User.find(params[:user_id]).events)
    render 'api/events/index'
  end
end
