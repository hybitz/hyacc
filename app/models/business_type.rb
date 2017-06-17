class BusinessType < ApplicationRecord

  def deemed_tax_percent
    deemed_tax_ratio * 100
  end

end