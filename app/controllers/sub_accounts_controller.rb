class SubAccountsController < Base::HyaccController

  def index
    @sub_accounts = load_sub_accounts(params[:account_id], params)
    
    respond_to do |format|
      format.html { render :partial => 'common/get_sub_accounts' }
      format.xml  { render :xml => @sub_accounts }
      format.json { render :json => @sub_accounts.collect{|sa| {:id=>sa.id, :name=>sa.name}}}
    end
  end

end
