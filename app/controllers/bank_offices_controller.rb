class BankOfficesController < Base::BasicMasterController
  view_attribute :deleted_types
  
  def add_bank_office
    @bank_office = BankOffice.new
  end  
  
end
