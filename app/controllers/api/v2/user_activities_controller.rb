class Api::V2::UserActivitiesController < Api::V2::BaseController
  respond_to :json

  def index
    offset = (params[:offset] || 0).to_i
    limit  = (params[:limit] || 200).to_i

    @activities = User
      .find(params[:user_id])
      .activities
      .where('value <> 0')
      .order('ts DESC')
      .slice(offset, limit)

    render 'api/v2/activities/index'
  end


  def activities
    @activities = User
      .find(params[:user_id])
      .activities
      .where("(model_name='Internal' or (string_to_array(tags, ', ') && '{watch,follow}'))")

    render 'api/v2/activities/index'
  end

  def achievements
    @achievements = User
      .find(params[:user_id])
      .achievements

    render 'api/v2/achievements/index'
  end

  def entities
    @entities = EntityDecorator.decorate_collection(User.find(params[:user_id]).entities)
    render 'api/v2/entities/index'
  end

end
