class SubAccountsController < Base::HyaccController

  def index
    @sub_accounts = load_sub_accounts(params[:account_id], params)
    # 寄付金は補助の先頭に「その他」を表示（補助が選ばれる前の状態で寄付先フォーム不要にし、分離を保つ）
    # 本処理は、寄付金の補助科目に「その他」が存在することを前提とする。
    account = Account.find_by(id: params[:account_id])
    if account&.path&.include?(ACCOUNT_CODE_DONATION)
      others = @sub_accounts.find { |sa| sa.code == SUB_ACCOUNT_CODE_DONATION_OTHERS }
      @sub_accounts = [others] + (@sub_accounts - [others]) if others
    end

    respond_to do |format|
      format.html { render :partial => 'common/get_sub_accounts' }
      format.xml  { render :xml => @sub_accounts }
      format.json { render :json => @sub_accounts.collect{|sa| {:id=>sa.id, :name=>sa.name}}}
    end
  end

end
