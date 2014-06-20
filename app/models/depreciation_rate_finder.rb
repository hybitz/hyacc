class DepreciationRateFinder < Base::Finder
  def list
    DepreciationRate.find(:all, :order=>'durable_years')
  end
end
