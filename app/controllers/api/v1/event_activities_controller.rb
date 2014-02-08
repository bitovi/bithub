class Api::V1::EventActivitiesController < Api::V1::BaseController
  before_filter :authenticate_user!, except: [:index]
  skip_load_and_authorize_resource :only => :index
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  def index
    @activities = ActivityDecorator.decorate_collection(Event.find(params[:event_id]).activities)
    render 'api/v1/activities/index'
  end

  def create_upvote
    authorize! :create_upvote, Upvote, :message => "No right to create an upvote!"
    event = Event.find(params[:event_id])
    upvote = Upvote.create_based_on_rule(current_user, event)
    if upvote
      render :json => upvote
    else
      render :json => {
        message: t('api.event_activities.errors.already_upvoted'),
        errors: upvote.errors.full_messages
      }, :status => 406
    end
  end

  def create_award
    authorize! :create_award, Award, :message => "No right to create an award!"
    event = Event.find(params[:event_id])

    begin
      award = Award.create_based_on_strategy(current_user, event, strategy: :double_parents_upvotes)
      render :json => award
    rescue EventHasNoParentException => e
      render :json => { message: t('api.event_activities.errors.has_no_parent'), errors: award.errors.full_messages }, :status => 406
    rescue ActiveRecord::RecordInvalid => e
      render :json => { message: t('api.event_activities.errors.already_awarded'), errors: award.errors.full_messages }, :status => 406
    end
  end

  def destroy_upvote
    authorize! :destroy_upvote, Upvote, :message => "No right to destroy an upvote!"
    u = Upvote.where({ applies_to_id: params[:event_id], actor_id: current_user.id }).first

    if u && u.destroy
      render :json => { message: "Deleted" }, :status => 200
    else
      render :json => { message: "Not found!" }, :status => 404
    end
  end
  
  def create_anteup
    authorize! :create_award, Anteup, :message => "No right to create an anteup!"
    render :json => { message: 'Coming soon.', errors: [] }, :status => 200
  end

end
