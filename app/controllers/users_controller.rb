class UsersController < ApplicationController

  def activities
    render :json => User.find(params[:id]).activities.to_json
  end

end
