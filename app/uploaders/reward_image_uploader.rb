require 'carrierwave/processing/rmagick'

class RewardImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

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
    process :resize_and_pad => [240, 240, "#ffffff"]
  end
end
