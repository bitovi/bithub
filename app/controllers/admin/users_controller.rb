class Admin::UsersController < Admin::AdminController
  def index
    @users = User.page params[:page]
    render 'index'
  end
end
