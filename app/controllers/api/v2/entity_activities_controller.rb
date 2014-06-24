class Api::V2::EntityActivitiesController < Api::V2::BaseController
  before_filter :authenticate!

  # load_and_authorize_resource
  # skip_load_and_authorize_resource :only => :index

  def index
    event = Event.find params[:event_id]
    @activities = ActivityDecorator.decorate_collection event.activities
    render 'api/v1/activities/index'
  end

  def create_award
    authorize! :create_award, Award, :message => "No right to create an award!"

    if (award = Actions::Awarder.new(current_user, Entity.find(params[:event_id]))).award
      render :json => award
    else
      render :json => { message: "Error of some kind." }, :status => 404
    end
  end

  def create_upvote
    authorize! :create_upvote, Upvote, :message => "No right to create an upvote!"
    if (upvote = Actions::Upvoter.new(current_user, Entity.find_by_id(params[:event_id])).upvote)
      render :json => upvote
    else
      render :json => {
        message: t('api.event_activities.errors.already_upvoted'),
        errors: upvote.errors.full_messages
      }, :status => 406
    end
  end

  def destroy_upvote
    authorize! :destroy_upvote, Upvote, :message => "No right to destroy an upvote!"
    if Actions::Upvoter.new(current_user, Entity.find(params[:event_id])).unupvote
      render :json => { message: "Deleted" }, :status => 200
    else
      render :json => { message: "Not found!" }, :status => 404
    end
  end

end
