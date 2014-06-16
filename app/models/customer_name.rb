class CustomerName < ActiveRecord::Base
  belongs_to :customer
  
  validates_presence_of :formal_name
  validates_presence_of :name
  
  attr_accessor :_destroy
  
  def self.get_current(customer_id)
    self.get_at(customer_id, Date.today)
  end
  
  def self.get_at(customer_id, date)
    CustomerName.where('customer_id=? and start_date <= ?', customer_id, date).order('start_date desc').first
  end

end
