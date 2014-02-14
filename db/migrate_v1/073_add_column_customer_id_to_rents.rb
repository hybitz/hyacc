# -*- encoding : utf-8 -*-
class AddColumnCustomerIdToRents < ActiveRecord::Migration

  def self.up
    
    add_column :rents, "customer_id", :integer, :null=>false
    
    # カラム情報を最新にする
    Rent.reset_column_information

    # 取引先マスタに登録
    code = 600
    Rent.find(:all).each do |r|
      customer = Customer.find_by_name(r.landlord_name)
      if customer.nil?
        customer = Customer.new
        customer.code = code.to_s
        customer.name = r.landlord_name
        customer.formal_name = r.landlord_name
        customer.address = r.landlord_address
        customer.is_order_placement = true
        customer.save!
        r.update_attributes(:customer_id => customer.id)
      else
        r.update_attributes(:customer_id => customer.id)
      end
      code += 1
    end
  end

  def self.down
    Customer.delete_all("id > 5")
    remove_column :rents, "customer_id"
  end
end
