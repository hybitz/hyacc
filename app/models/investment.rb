class Investment < ActiveRecord::Base
  belongs_to :customer
  
  attr_accessor :buying_or_selling
end
