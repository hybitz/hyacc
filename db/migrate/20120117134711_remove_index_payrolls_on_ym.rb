class RemoveIndexPayrollsOnYm < ActiveRecord::Migration
  def self.up
    remove_index "payrolls", :name => "index_payrolls_on_ym"
  end

  def self.down
    add_index "payrolls", "ym", :name => "index_payrolls_on_ym"
  end
end
