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
      post "/", {:upload => Rack::Test::UploadedFile.new(
        "/Users/hukl/Desktop/Cleanup/Image_23.jpg",
        "image/jpeg"
      ),
      :expires_in => 10
      }
    end

    cached_file = CachedFile.last
    assert_equal "Image_23.jpg", cached_file.original_filename
    assert_equal 10, (cached_file.expires_at.to_i - cached_file.created_at.to_i)
  end

  test "get one new url" do
    assert_difference "CachedFile.count", +1 do
      get "/new"
    end

    response = JSON.parse( last_response.body )
    assert_equal 1, response.size
  end

  test "get ten new urls" do
    assert_difference "CachedFile.count", +10 do
      get "/new/10"
    end

    response = JSON.parse( last_response.body )
    assert_equal 10, response.size
  end

  test "upload to generated uuid" do
    get "/new"
    response = JSON.parse( last_response.body )

    upload_uri = response.first + "/Image_23.jpg"

    put upload_uri, {:upload => Rack::Test::UploadedFile.new(
      "/Users/hukl/Desktop/Cleanup/Image_23.jpg",
      "image/jpeg"
    )}

    cached_file = CachedFile.last
    assert File.exists?( cached_file.absolute_filepath )
    assert_equal "Image_23.jpg", cached_file.original_filename


    get last_response.body
    assert last_response.headers["Content-Disposition"] =~ /Image_23\.jpg/
  end


end
