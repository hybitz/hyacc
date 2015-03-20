class BankOfficesController < Base::BasicMasterController
  respond_to :json
  
  def index
    bank_offices = BankOffice.where(:bank_id => params[:bank_id]).not_deleted
    respond_with bank_offices
  end
  
end
