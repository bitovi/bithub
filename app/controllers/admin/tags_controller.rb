class Admin::TagsController < Admin::AdminController

  def index
    @tags = Tag.page params[:page]
    render 'index'
  end

  def new
    @tag = Tag.new
    render :new
  end

  def edit
    @tag = Tag.find(params[:id])
    render :edit
  end

  def create
    aliases = params[:tag].delete(:aliases)
    @tag = Tag.new
    @tag.aliases = aliases.split(',')
    @tag.assign_attributes(params[:tag])
    if @tag.save
      redirect_to admin_tags_path
    else
      render :text => 'jebiga'
    end
  end

  def update
    @tag = Tag.find(params[:id])
    aliases = params[:tag].delete(:aliases)
    @tag.aliases = aliases.split(',')
    @tag.assign_attributes(params[:tag])
    if @tag.save
      redirect_to admin_tags_path
    else
      render :text => 'jebiga'
    end
  end

  def destroy
  end
end
