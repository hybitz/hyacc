class AddColumnFirstNameKanaOnEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :first_name_kana, :string
  end
end
