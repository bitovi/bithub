class Api::ActivitiesController < ApplicationController
  respond_to :json
  protect_from_forgery :except => [:create, :update]

  def upvote
    begin
      event = Event.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return render :json => e, :status => 404
    end

    if Upvote.where({:applies_to_id => event, :actor_id => current_user}).length == 0      
      render :json => Upvote.create_upvote(current_user, event)
    else
      render :json => {:errors => ['Already upvoted']}
    end
  end

  def anteup
    begin
      event = Event.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return render :json => e, :status => 404
    end

    if Anteup.where({:applies_to_id => event, :actor_id => current_user}).length == 0      
      render :json => Anteup.create_anteup(current_user, event, params[:value])
    else
      render :json => {:errors => ['Anteup already placed']}
    end
  end

  def award
    begin
      event = Event.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return render :json => e, :status => 404
    end

    if Award.where({:applies_to_id => event, :actor_id => current_user}).length == 0      
      render :json => Award.create_award(current_user, event)
    else
      render :json => {:errors => ['Event already awarded']}
    end
  end

end
