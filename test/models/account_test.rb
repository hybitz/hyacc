require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  def test_補助科目のキャッシュ
    assert_not_nil account = Account.where(sub_account_type: SUB_ACCOUNT_TYPE_NORMAL).first
    cache_key = [account.sub_account_type, account.id]
    account.sub_accounts_all
    assert Accounts::SubAccountsRequestCache.cache.key?(cache_key)

    Accounts::SubAccountsRequestCache.reset
    refute Accounts::SubAccountsRequestCache.cache.key?(cache_key)
  end

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

  def test_sub_accounts_ordered_for_select_寄付金の補助科目はその他が先頭になること
    account = Account.find_by(code: ACCOUNT_CODE_DONATION)
    ordered = account.sub_accounts_ordered_for_select
    assert_equal SUB_ACCOUNT_CODE_DONATION_OTHERS, ordered.first.code
  end

end
