class AddColumnLastNameKanaOnEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :last_name_kana, :string
  end
end
