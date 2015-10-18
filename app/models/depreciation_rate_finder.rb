class DepreciationRateFinder < Daddy::Model

  def list
    DepreciationRate.find_all_by_date(Date.today)
  end

end
