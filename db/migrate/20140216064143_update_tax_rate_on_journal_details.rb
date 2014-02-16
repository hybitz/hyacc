class UpdateTaxRateOnJournalDetails < ActiveRecord::Migration
  include HyaccConstants

  def up
    JournalDetail.update_all(['tax_rate = ?', 0.05], ['tax_type in (?, ?)', TAX_TYPE_INCLUSIVE, TAX_TYPE_EXCLUSIVE])
  end

  def down
  end
end
