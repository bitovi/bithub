class Api::TagsController < ApplicationController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors
  before_filter :authenticate_user!, :only => ['create', 'update']

  def index

    if (params[:type]) && Tag.types.include?(params[:type])
      @tags = Tag.send(params[:type].pluralize).all      
    else
      @tags = Tag.all
    end

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
