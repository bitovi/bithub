class Admin::UsersController < Admin::AdminController

  def index
    @users = User.page params[:page]
    render 'index'
  end
  
  def edit
    @user = User.find(params[:id])
    @internal = Internal.new
    render 'edit'
  end

  def update
    @user = User.find(params[:id])
    @user.internals << Internal.new(params[:internal])
    if @user.save!
      redirect_to edit_admin_user_path(@user)
    else
      render text: 'kita'
    end
  end

  def delete_activity
  end
end
