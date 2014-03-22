class HouseworkFinder < Base::Finder

  def list
    raise ArgumentError.new("会計年度の指定がありません。") unless fiscal_year.to_i > 0
    Housework.where(:company_id => company_id, :fiscal_year => fiscal_year).first
  end

end
