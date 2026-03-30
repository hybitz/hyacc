class AddColumnDutyDescriptionOnEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :duty_description, :string
  end
end

