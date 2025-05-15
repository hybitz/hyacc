class ChangeCollation < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.connection.tables.each do |table_name|
      execute "ALTER TABLE #{table_name} CONVERT TO CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci;"
    end
  end
end
