module Branches

  def branch
    @_branch ||= Branch.where(deleted: false).first
  end

  def branch_params
    {
      :code => '1234',
      :formal_name => '正式テスト部門',
      :name => 'テスト部門',
      :parent_id => nil
    }
  end

  def invalid_branch_params
    {
      :code => '1234',
      :formal_name => ''
    }
  end

end
