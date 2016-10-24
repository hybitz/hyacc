class DeleteDuplicateCustomers < ActiveRecord::Migration
  def up
    Customer.find_each do |c|
      if c.deleted? and c.disabled and c.formal_name.blank?
        puts "#{c.id}: #{c.code}"
        c.destroy
      end
    end
  end

  def down
  end
end
