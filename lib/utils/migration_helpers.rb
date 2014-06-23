module MigrationHelpers

  #
  # 外部キーを設定する。
  #
  def foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"

    execute %{alter table #{from_table}
              add constraint #{constraint_name}
              foreign key (#{from_column})
              references #{to_table}(id) ON DELETE RESTRICT ON UPDATE RESTRICT}
  end

  #
  # 外部キーを削除する。
  # 
  def drop_foreign_key(from_table, from_column)
    constraint_name = "fk_#{from_table}_#{from_column}"

    execute %{alter table #{from_table}
                  drop foreign key #{constraint_name}}
  end
  
  
end
