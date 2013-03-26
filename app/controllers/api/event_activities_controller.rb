class Api::EventActivitiesController < ApplicationController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors
  before_filter :authenticate_user!, :except => ['index']

  def index
    @activities = ActivityDecorator.decorate_collection(Event.find(params[:event_id]).activities)
    render 'api/activities/index'
  end

  def create_upvote
    event = Event.find(params[:event_id])

    if Upvote.where({:applies_to_id => event, :actor_id => current_user}).length == 0      
      upvote = Upvote.create_upvote(current_user, event)
      render :json => upvote
    else
      render :json => {:error => t('errors.messages.already_upvoted')}, :status => 500
    end
  end

  def create_anteup
    event = Event.find(params[:event_id])

    if Anteup.where({:applies_to_id => event, :actor_id => current_user}).length == 0      
      anteup = Anteup.create_anteup(current_user, event, params[:value])
      render :json => anteup
    else
      render :json => {:error => t('errors.messages.already_anteuped')}, :status => 500
    end
  end

  def create_award
    event = Event.find(params[:event_id])

    if Award.where({:applies_to_id => event, :actor_id => current_user}).length == 0      
      award = Award.create_award(current_user, event)
      render :json => award
    else
      render :json => {:error => t('errors.messages.already_awarded')}, :status => 500
    end
  end


  private

  def show_errors(e)
    render :json => {:error => e.message}, :status => 500
  end

end
