class Api::TagsController < Api::ApiController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors

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
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      render :show
    else
      reder json: { error: @tag.errors.messages }
    end
  end

end
