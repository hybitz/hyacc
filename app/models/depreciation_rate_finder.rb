class DepreciationRateFinder < Base::Finder

  def list
    DepreciationRate.order('durable_years')
  end

end
