class Api::UserActivitiesController < ApplicationController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors

  def index
    @activities = ActivityDecorator.decorate_collection(User.find(params[:user_id]).activities)
    render 'api/activities/index'
  end

end
