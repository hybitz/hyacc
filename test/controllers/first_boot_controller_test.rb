require 'test_helper'

class FirstBootControllerTest < ActionController::TestCase

  def test_初期画面
    db_reset

    get :index
    assert_response :success
    assert_template :index
  end

  def test_既に初期登録済み
    assert User.count > 0

    get :index
    assert_response :redirect
    assert_redirected_to root_path
  end

  def test_個人事業主として登録
    db_reset

    post :create, :params => {
        :company => {
          :name => 'テスト会社', :founded_date => Date.today, :type_of => COMPANY_TYPE_PERSONAL,
          :business_offices_attributes => {
            '0' => {
              :prefecture_code => '01', :address1 => '住所1', :address2 => '住所2'
            }
          }
        },
        :fy => {:tax_management_type => TAX_MANAGEMENT_TYPE_EXEMPT},
        :e => {:last_name => '山田', :first_name => '花子', :sex => SEX_TYPE_F, :birth => 20.years.ago},
        :u => {:login_id => 'test', :password => 'testtest', :email => 'test@example.com'}
    }

    assert @c = assigns(:c)
    assert_response :redirect
    assert_redirected_to root_path
  end

  def test_株式会社として登録
    db_reset

    post :create, :params => {
        :company => {
          :name => 'テスト会社', :founded_date => Date.today, :type_of => COMPANY_TYPE_COLTD,
          :business_offices_attributes => {
            '0' => {
              :prefecture_code => '01', :address1 => '住所1', :address2 => '住所2'
            }
          }
        },
        :fy => {:tax_management_type => TAX_MANAGEMENT_TYPE_EXCLUSIVE},
        :e => {:last_name => '山田', :first_name => '花子', :sex => SEX_TYPE_F, :birth => 30.years.ago},
        :u => {:login_id => 'test', :password => 'testtest', :email => 'test@example.com'}
    }

    assert @c = assigns(:c)
    assert_response :redirect
    assert_redirected_to root_path
  end

  def test_登録_入力エラー
    db_reset

    post :create, :params => {
        :company => {
          :name => '', :founded_date => Date.today, :type_of => COMPANY_TYPE_PERSONAL,
          :business_offices_attributes => {
            '0' => {
              :prefecture_code => '01', :address1 => '住所1', :address2 => '住所2'
            }
          }
        },
        :fy => {:tax_management_type => TAX_MANAGEMENT_TYPE_EXEMPT},
        :e => {:last_name => '', :first_name => '', :sex => SEX_TYPE_F},
        :u => {:login_id => '', :password => '', :email => ''}
    }

    assert_response :success
    assert_template :index
  end

  private

  def db_reset
    assert User.delete_all
    assert Account.delete_all
    assert SubAccount.delete_all
    assert SimpleSlipTemplate.delete_all
    assert BusinessType.delete_all
  end

end
