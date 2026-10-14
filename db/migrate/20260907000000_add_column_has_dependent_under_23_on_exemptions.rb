class AddColumnHasDependentUnder23OnExemptions < ActiveRecord::Migration[8.1]
  def change
    add_column :exemptions, :has_dependent_under_23, :boolean
  end
end
