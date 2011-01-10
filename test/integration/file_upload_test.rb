$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), ".."))
require 'test_helper'

class FileUploadTest < Test::Unit::TestCase

  def setup
    CachedFile.delete_all
  end

  # test "upload params" do
  #   xxx = {'data' => Rack::Test::UploadedFile.new(
  #     "/Users/hukl/Desktop/Cleanup/Image_23.jpg",
  #     "image/jpeg"
  #   )}
  # 
  # end
  # 
  test "uploading a file" do
    assert_difference "CachedFile.count", +1 do
      post "/v3/", {:upload => Rack::Test::UploadedFile.new(
        "test/fixtures/home.jpg",
        "image/jpeg"
      ),
      :expires_in => 10
      }
    end
  
    cached_file = CachedFile.last
    assert_equal "home.jpg", cached_file.original_filename
    assert_equal 10, (cached_file.expires_at.to_i - cached_file.created_at.to_i)
  end

  test "upload to generated uuid" do
    upload_uri = "/v3/#{uuid}"
  
    header "Content-Disposition", "attachment; filename=\"home.jpg\""
    put upload_uri, {:upload => Rack::Test::UploadedFile.new(
      "test/fixtures/home.jpg",
      "image/jpeg"
    )}
    
    assert last_response.ok?, "put should have returned ok"
    cached_file = CachedFile.last
    assert File.exists?( cached_file.absolute_filepath )
    assert_equal "home.jpg", cached_file.original_filename
  
    get last_response.body
    assert last_response.headers["Content-Disposition"] =~ /home\.jpg/
  end
  
  test "options with Access-Control-Allow-Origin header" do
    header "CONTENT_DISPOSITION", "attachment, filename=bla"
    header "ORIGIN", "http://www.hoccer.com"
   
    request "/v3/#{uuid}", :method => "PUT", :params => {"api_key" => "37d4b750fc95012d14a7109add515cd4"}

    assert last_response.ok?, "should response ok"
    assert_equal last_response.headers["Access-Control-Allow-Origin"], "http://www.hoccer.com"
  end
  
  private 

  def uuid
    UUID.new.generate
  end

end
