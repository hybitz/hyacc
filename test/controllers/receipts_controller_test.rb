require 'test_helper'

class ReceiptsControllerTest < ActionController::TestCase

  def test_領収書のダウンロード
    sign_in user
    get :show, :params => {:id => receipt.id}
    assert_response :success
    assert_equal Digest::MD5.file(receipt.file.path), Digest::MD5.hexdigest(@response.body)
  end

end
