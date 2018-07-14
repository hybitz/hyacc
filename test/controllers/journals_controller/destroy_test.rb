require 'test_helper'

class JournalsController::CrudTest < ActionController::TestCase

  def setup
    sign_in user
  end

  def test_削除
    jh = Journal.find(10)

    assert_difference 'Journal.count', -1 do
      delete :destroy, :params => {:id => jh.id, :lock_version => jh.lock_version}
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
  
    assert_raise(ActiveRecord::RecordNotFound) {
      JournalHeader.find(jh.id)
    }
  end
  
  def test_削除_ajax
    jh = Journal.find(10)
    
    assert_difference 'Journal.count', -1 do
      delete :destroy, xhr: true, params: {id: jh.id, lock_version: jh.lock_version}
    end
  
    assert_response :success
    assert_template nil
  end
  
  def test_前払振替の伝票は削除できない
    jh = Journal.find(5695)
    
    assert_no_difference 'Journal.count' do
      delete :destroy, params: {id: jh.id, lock_version: jh.lock_version}
    end

    assert_response :redirect
    assert_redirected_to action: 'index'
  end
  
  def test_台帳登録の伝票は削除できない
    jh = Journal.find(5697)

    assert_no_difference 'Journal.count' do
      delete :destroy, params: {id: jh.id, lock_version: jh.lock_version}
    end

    assert_response :redirect
    assert_redirected_to action: 'index'
  end

end
