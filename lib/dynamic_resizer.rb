require 'RMagick'

class DynamicResizer

  WIDTH_LIMIT = 0
  HEIGHT_LIMIT = 0
  AVAILABLE_EXTENSIONS = ["jpg","jpeg","png","gif"]

  def initialize(fullpath, opts = {})
    @fullpath = fullpath
    @dirname = File.dirname(fullpath)
    @filename = File.basename(fullpath)

    @width_limit = opts[:width_limit] || WIDTH_LIMIT
    @height_limit = opts[:heigth_limit] || HEIGHT_LIMIT

    if @props = parse_filename(@filename)
      self
    else
      false
    end
  end

  def resize
    props = parse_filename( @filename )
    return false unless props && validate(props)
    
    image = Magick::Image.read(make_filepath(props[:origin_filename])).first
    image.change_geometry!(props[:width].to_s + "x" + props[:height].to_s) { |cols, rows, img|
      img.resize!(cols, rows).to_blob
    }
  end

  def resize_and_save
    image = resize()
    filepath = make_filepath(@props[:filename])
    File.open(filepath, "wb") {|f| f.write(image)} ? image : false
  end

  def mimetype
    "image/" + @props[:extension] if @props
  end

  private

  def parse_filename(filename)
    regex_str = "([0-9]+)x([0-9]+)_(.*\.(" + AVAILABLE_EXTENSIONS.join('|') + "))$"
    regex = Regexp.new(regex_str, true)

    matched = regex.match(filename)
    return false unless matched = regex.match(filename)

    {
      :filename => matched[0],
      :width => matched[1].to_i,
      :height => matched[2].to_i,
      :origin_filename => matched[3],
      :extension => matched[4]
    }
  end

  def make_filepath(filename)
    File.join( Rails.root, "public", @dirname, filename)
  end

  def validate(props)
    validate_filepath(props[:origin_filename]) && validate_geometry(props[:width], props[:height])
  end

  def validate_filepath(filename)
    File.exists? make_filepath(filename)
  end

  def validate_geometry(width, height)
    [width, 
     height, 
     width > 0, 
     height > 0,
     (@width_limit == 0) || (@width_limit && width <= @width_limit),
     (@height_limit == 0) || (@height_limit && height <= @height_limit)
    ].all?
  end
  
end
