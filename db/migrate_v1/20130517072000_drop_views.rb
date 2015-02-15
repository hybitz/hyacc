class DropViews < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute('drop view v_monthly_ledgers')
    ActiveRecord::Base.connection.execute('drop view v_taxes')
  end

  def down
  end
end
