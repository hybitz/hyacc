class UpdateNameAndFormalNameOnCustomers < ActiveRecord::Migration
  def change
    Customer.find_each do |c|
      cn = CustomerName.get_current(c.id)
      unless cn
        puts c.id
        next
      end
      c.name = cn.name
      c.formal_name = cn.formal_name
      c.save!
    end
  end
end
