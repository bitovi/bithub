class Api::V2::EntityActivitiesController < Api::V2::BaseController
  before_filter :authenticate!

  def index
    event = Event.find params[:entity_id]
    @activities = ActivityDecorator.decorate_collection event.activities
    render 'api/v2/activities/index'
  end

  def create_award
    authorize! :create_award, Award, :message => "No right to create an award!"

    if (award = Activities::Awarder.new(current_user, Entity.find(params[:entity_id]))).award
      render :json => award
    else
      render :json => { message: "Error of some kind." }, :status => 404
    end
  end

  def create_upvote
    authorize! :create_upvote, Upvote, :message => "No right to create an upvote!"
    if (upvote = Activities::Upvoter.new(current_user, Entity.find_by_id(params[:entity_id])).upvote)
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
    if Activities::Upvoter.new(current_user, Entity.find_by_id(params[:entity_id])).unvote
      render :json => { message: "Deleted" }, :status => 200
    else
      render :json => { message: "Not found!" }, :status => 404
    end
  end

end
