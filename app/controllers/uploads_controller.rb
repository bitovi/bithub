class UploadsController < ActionController::Base

  def index

    image = DynamicResizer.new(request.fullpath)

    if image && resized = image.resize_and_save
      send_data resized, type: image.mimetype, disposition: "inline"
    else
      render :json => { :error => "Couldn't resize image." }, :status => 500
    end

  end

end
