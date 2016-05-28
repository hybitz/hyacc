require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  def test_ルートとなる勘定科目
    expected = %w{ 資産の部 負債の部 純資産の部 収益の部 費用の部 諸口 }
    actual = Account.where(:parent_id => nil)

    assert_equal expected.size, actual.count
    expected.each do |name|
      assert actual.where(:name => name).present?
    end
  end

  def test_save_fail_by_account_type
    parent = Account.where(:parent_id => nil, :account_type => ACCOUNT_TYPE_ASSET).first
    a = Account.new
    a.attributes = parent.attributes
    a.code = 'testcode'
    a.name = 'テスト名称'
    a.parent_id = parent.id
    
    a.account_type = ACCOUNT_TYPE_DEBT
    assert_equal( false, a.save, "親と違う勘定科目区分に変更はできない")
  end

  def test_save_fail_by_dc_type
    assert parent = Account.where(:parent_id => nil, :account_type => ACCOUNT_TYPE_ASSET).first

    a = Account.new
    a.attributes = parent.attributes
    a.code = 'testcode'
    a.name = 'テスト名称'
    a.parent_id = parent.id
    
    a.dc_type = parent.opposite_dc_type
    assert a.invalid?, "親と違う貸借区分に変更はできない"
  end
  
  def test_is_leaf_on_settlement_report
    a = Account.find_by_code('3170')
    assert_equal( true, a.is_leaf_on_settlement_report )

    a = Account.find_by_code('3171')
    assert_equal( false, a.is_leaf_on_settlement_report )

    a = Account.find_by_code('3172')
    assert_equal( false, a.is_leaf_on_settlement_report )
  end
  
end
