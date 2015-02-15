class UpdateDisabledOnCustomers < ActiveRecord::Migration
  def change
    Customer.find_each do |c|
      c.update_column(:disabled, true) if c.deleted?
      c.update_column(:deleted, false)
    end
  end
end
