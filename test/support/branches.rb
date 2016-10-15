module Branches

  def branch
    @_branch ||= Branch.where(:deleted => false).first
  end

  def valid_branch_params
    {
      :code => '1234',
      :name => 'テスト部門',
      :parent_id => nil
    }
  end

  def invalid_branch_params
    {
      :code => '1234',
      :name => ''
    }
  end

end
