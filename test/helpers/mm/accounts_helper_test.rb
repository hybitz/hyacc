require 'test_helper'

class Mm::AccountsHelperTest < ActionView::TestCase
  include Accounts

  def test_convert_account_to_json_without_children
    # 子要素を持たない勘定科目を取得
    account = Account.where("id NOT IN (SELECT DISTINCT parent_id FROM accounts WHERE parent_id IS NOT NULL)").first
    assert account.present?, "子要素を持たない勘定科目が見つかること"
    assert account.children.empty?, "勘定科目に子要素がないこと"
    
    result = convert_account_to_json(account)
    
    assert result.html_safe?
    assert_match(/id: #{account.id}/, result)
    assert_match(/#{account.code}/, result)
    assert_match(/#{account.name}/, result)
    assert_match(/children: \[\]/, result)
  end

  def test_convert_account_to_json_with_children
    account = Account.find_by_code('1100') # 流動資産 - 子要素を持つ
    assert account.children.present?, "勘定科目に子要素があること"
    
    result = convert_account_to_json(account)
    
    assert result.html_safe?
    assert_match(/id: #{account.id}/, result)
    assert_match(/children: \[/, result)
    
    # 子要素が含まれていることを確認
    account.children.each do |child|
      assert_match(/id: #{child.id}/, result)
    end
  end

  def test_convert_account_to_json_nested_structure
    parent = Account.find_by_code('1100') # 流動資産
    child = parent.children.first
    
    result = convert_account_to_json(parent)
    
    # ネストされたJSON構造が含まれていることを確認
    assert_match(/\{id: #{parent.id}.*children: \[.*\{id: #{child.id}/m, result)
  end

  def test_convert_account_to_json_multiple_children
    account = Account.find_by_code('1400') # 有価証券 - 複数の子要素を持つ
    assert account.children.size > 1, "勘定科目に複数の子要素があること"
    
    result = convert_account_to_json(account)
    
    # 複数の子要素がカンマで区切られていることを確認
    child_count = result.scan(/,\{id:/).size
    assert_equal account.children.size - 1, child_count, "#{account.children.size}個の子要素に対して#{account.children.size - 1}個のカンマがあること"
  end
end

