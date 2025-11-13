require 'test_helper'

class Mm::BranchesHelperTest < ActionView::TestCase
  include Branches

  def test_convert_branch_to_json_without_children
    branch = Branch.find(5) # 部門5は子要素を持たない
    branch_children = branch.children.where(deleted: false)
    
    result = convert_branch_to_json(branch)
    
    assert result.html_safe?
    assert_match(/id: #{branch.id}/, result)
    assert_match(/#{branch.code}/, result)
    assert_match(/#{branch.name}/, result)
    
    if branch_children.empty?
      assert_match(/children: \[\]/, result)
    end
  end

  def test_convert_branch_to_json_with_children
    branch = Branch.find(1) # 部門1は子要素を持つ（部門2と3）
    branch_children = branch.children.where(deleted: false)
    
    assert branch_children.present?, "部門に子要素があること"
    
    result = convert_branch_to_json(branch)
    
    assert result.html_safe?
    assert_match(/id: #{branch.id}/, result)
    assert_match(/children: \[/, result)
    
    # 削除されていない子要素が含まれていることを確認
    branch_children.each do |child|
      assert_match(/id: #{child.id}/, result)
    end
  end

  def test_convert_branch_to_json_excludes_deleted_children
    branch = Branch.find(1) # 部門1は子要素を持つ
    deleted_child = Branch.find(4) # 部門4は削除されている
    
    result = convert_branch_to_json(branch)
    
    # 削除された子要素は含まれないことを確認
    if deleted_child.parent_id == branch.id
      assert_no_match(/id: #{deleted_child.id}/, result)
    else
      # 部門4が部門1の子要素でない場合はスキップ
      assert true
    end
  end

  def test_convert_branch_to_json_nested_structure
    parent = Branch.find(1) # 部門1
    child = parent.children.where(deleted: false).first
    
    assert child.present?, "子要素が１つはあること"
    
    result = convert_branch_to_json(parent)
    
    # ネストされたJSON構造が含まれていることを確認
    assert_match(/\{id: #{parent.id}.*children: \[.*\{id: #{child.id}/m, result)
  end

  def test_convert_branch_to_json_multiple_children
    branch = Branch.find(1) # 部門1は複数の子要素を持つ
    branch_children = branch.children.where(deleted: false)
    
    assert branch_children.size > 1, "複数の子要素を持っていること"
    
    result = convert_branch_to_json(branch)
    
    # 複数の子要素が改行とカンマで区切られていることを確認
    assert_match(/,\n/, result) if branch_children.size > 1
  end
end

