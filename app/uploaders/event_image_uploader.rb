require 'carrierwave/processing/rmagick'

class EventImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include Sprockets::Helpers::RailsHelper

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    # "/uploads/fallback/" + [version_name, "default.png"].compact.join('_')
    ""
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  version :thumb do
    process :resize_to_fit => [60, 60]
  end

  version :large do
    process :resize_to_fill => [800, 800]
  end
end
