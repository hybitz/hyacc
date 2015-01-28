class BankOfficesController < Base::BasicMasterController
  view_attribute :deleted_types
  
  def index
    bank_offices = BankOffice.where(:bank_id => params[:bank_id]).not_deleted

    respond_to do |format|
      format.json  { render :json => bank_offices }
    end
  end
  
end
