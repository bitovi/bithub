class Api::EventActivitiesController < Api::ApiController
  before_filter :authenticate_user!, except: [:index]
  skip_load_and_authorize_resource :only => :index
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  def index
    @activities = ActivityDecorator.decorate_collection(Event.find(params[:event_id]).activities)
    render 'api/activities/index'
  end

  def create_upvote
    authorize! :create_upvote, Upvote, :message => "No right to create an upvote!"
    upvote = Upvote.create({actor: current_user, applies_to: Event.find(params[:event_id])})
    if upvote.persisted?
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
    award = Award.create_and_fullfill(current_user, Event.find(params[:event_id]))
    if award.persisted?
      render :json => award
    else
      render :json => {
        message: t('api.event_activities.errors.already_awarded'),
        errors: award.errors.full_messages
      }, :status => 406
    end
  end
  
  def create_anteup
    authorize! :create_award, Anteup, :message => "No right to create an anteup!"
    render :json => { message: 'Coming soon.', errors: [] }, :status => 200
  end

end
