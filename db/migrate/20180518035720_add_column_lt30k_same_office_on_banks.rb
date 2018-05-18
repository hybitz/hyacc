class AddColumnLt30kSameOfficeOnBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :banks, :lt_30k_same_office, :integer
    add_column :banks, :ge_30k_same_office, :integer
    add_column :banks, :lt_30k_other_office, :integer
    add_column :banks, :ge_30k_other_office, :integer
    add_column :banks, :lt_30k_other_bank, :integer
    add_column :banks, :ge_30k_other_bank, :integer
  end
end
