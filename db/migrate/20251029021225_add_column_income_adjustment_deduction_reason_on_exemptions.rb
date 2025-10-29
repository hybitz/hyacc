class AddColumnIncomeAdjustmentDeductionReasonOnExemptions < ActiveRecord::Migration[7.2]
  def change
    add_column :exemptions, :income_adjustment_deduction_reason, :integer
  end
end
