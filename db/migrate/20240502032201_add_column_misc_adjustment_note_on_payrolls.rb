class AddColumnMiscAdjustmentNoteOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :misc_adjustment_note, :string
  end
end
