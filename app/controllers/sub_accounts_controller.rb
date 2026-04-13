class SubAccountsController < Base::HyaccController

  def index
    @sub_accounts = load_sub_accounts(params[:account_id], params)
    # 寄付金は補助の先頭に「その他」を表示（補助未選択時は寄付先フォーム不要にする）
    account = Account.find_by(id: params[:account_id])
    @sub_accounts = account.reorder_sub_accounts_for_select(@sub_accounts) if account

    respond_to do |format|
      format.html { render partial: 'common/get_sub_accounts' }
      format.xml  { render xml: @sub_accounts }
      format.json { render json: @sub_accounts.map {|sa| {id: sa.id, name: sa.name} } }
    end
  end

end
