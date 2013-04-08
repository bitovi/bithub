class Api::TagsController < ApplicationController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors
  before_filter :authenticate_user!, :only => ['create', 'update']

  def index
    @tags = Tag.all
    render :index
  end

  def categories
    @tags = Tag.categories.all
    render :index
  end

  def projects
    @tags = Tag.projects.all
    render :index
  end
  
  def feeds
    @tags = Tag.feeds.all
    render :index
  end

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      render :show
    else
      render :text => "some error"
    end
  end

  def update
    @tag = Tag.update_params(params[:tag])
    render :show
  end

end
