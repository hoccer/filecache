$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), ".."))
require 'test_helper'

class FileUploadTest < Test::Unit::TestCase

  def setup
    CachedFile.delete_all
  end

  test "upload params" do
    xxx = {'data' => Rack::Test::UploadedFile.new(
      "/Users/hukl/Desktop/Cleanup/Image_23.jpg",
      "image/jpeg"
    )}

  end

  test "uploading a file" do
    assert_difference "CachedFile.count", +1 do
      post "/", :upload => {
        :file => Rack::Test::UploadedFile.new(
          "/Users/hukl/Desktop/Cleanup/Image_23.jpg",
          "image/jpeg"
        ),
        :expires_in => 10
      }
    end

    puts CachedFile.last.inspect
  end

end
