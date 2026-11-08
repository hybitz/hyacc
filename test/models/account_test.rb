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

  def test_部門補助科目は会社ごとに分離される
    company_a = Company.find(1)
    company_b = Company.find(2)
    branch_a = company_a.branches.find(2) # company_id: 1, code: 102
    other_company_branch = company_b.branches.find_by_code(branch_a.code)
    account = Account.find_by_code(ACCOUNT_CODE_BRANCH_OFFICE)

    account.sub_accounts_all(company_id: company_a.id)
    assert Accounts::SubAccountsRequestCache.cache.key?([SUB_ACCOUNT_TYPE_BRANCH, company_a.id])
    assert_includes account.sub_accounts(company_id: company_a.id).map(&:id), branch_a.id
    assert_not_includes account.sub_accounts(company_id: company_a.id).map(&:id), other_company_branch.id
    assert_equal branch_a.id, account.get_sub_account_by_code(branch_a.code, company_id: company_a.id).id

    assert_includes account.sub_accounts(company_id: company_b.id).map(&:id), other_company_branch.id
    assert_not_includes account.sub_accounts(company_id: company_b.id).map(&:id), branch_a.id
    assert_equal other_company_branch.id, account.get_sub_account_by_code(branch_a.code, company_id: company_b.id).id
    assert_nil account.get_sub_account_by_id(other_company_branch.id, company_id: company_a.id)
    assert_nil account.get_sub_account_by_id(branch_a.id, company_id: company_b.id)
    assert account.has_sub_accounts?(company_id: company_b.id)
  end

  def test_部門補助科目は会社の指定が必須
    account = Account.find_by_code(ACCOUNT_CODE_BRANCH_OFFICE)
    assert_raises(ArgumentError) { account.sub_accounts }
    assert_raises(ArgumentError) { account.sub_accounts_all }
    assert_raises(ArgumentError) { account.get_sub_account_by_id(2) }
    assert_raises(ArgumentError) { account.get_sub_account_by_code('102') }
    assert_raises(ArgumentError) { account.has_sub_accounts? }
    assert_raises(ArgumentError) { Account.get_journalizable_accounts }
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

end
