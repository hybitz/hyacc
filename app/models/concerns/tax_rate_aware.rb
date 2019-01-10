module TaxRateAware
  extend ActiveSupport::Concern

  def tax_rate_percent
    (self.tax_rate.to_f * 100.0).to_i
  end

  def tax_rate_percent=(value)
    self.tax_rate = value.to_f / 100.0
  end

end