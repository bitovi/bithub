require 'spec_helper'

RSpec.describe DynamicResizer, :type => :libs do
  
  let(:origin_filename) { "foo_bar.jpg" }
  let(:width) { 400 }
  let(:height) { 300 }  
  let(:width_limit) { 1024 }
  let(:height_limit) { 768 }
  let(:filename) { width.to_s + "x" + height.to_s + "_" + origin_filename }
  let(:req_path) { "/public/images/" + filename }

  subject(:image) do
    DynamicResizer.new(req_path, {:width_limit => width_limit, :height_limit => height_limit})
  end
  
  describe "#parse_filename" do
    it "extract correct values from filename to props" do
      image.stub(:is_filepath_valid? => true)
      #props = image.parse_filename(image.filename)
      props = image.send(:parse_filename, image.filename)

      expect(props[:filename]).to eq filename
      expect(props[:width]).to eq width
      expect(props[:height]).to eq height
      expect(props[:origin_filename]).to eq origin_filename
    end
  end

  describe "#is_geometry_valid?" do
    it "validate width and height to be greater than 0" do
      expect(image.send(:is_geometry_valid?, 400,300)).to be
      expect(image.send(:is_geometry_valid?, -400,300)).to be_falsey
      expect(image.send(:is_geometry_valid?, 0,0)).to be_falsey
    end
    it "validate width and height to be less smaller than limit" do
      expect(image.send(:is_geometry_valid?, 400,300)).to be
      expect(image.send(:is_geometry_valid?, width_limit+1, height_limit)).to be_falsey
    end
  end

end  
