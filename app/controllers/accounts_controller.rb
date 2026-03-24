class AccountsController < Base::HyaccController

  # 税抜経理方式の場合は、勘定科目の税区分を取得
  # それ以外は、非課税をデフォルトとする
  def show
    account = Account.find(params[:id])
    requires_sub_accounts_reorder = false

    if account
      tax_type = current_company.get_tax_type_for(account)
      sub_accounts = HyaccUtil.sort_by_code(account.sub_accounts).collect{|sa| {id: sa.id, name: sa.name}}
      requires_sub_accounts_reorder = account.path.include?(ACCOUNT_CODE_DONATION)
    end

    render json: {tax_type: tax_type, sub_accounts: Array(sub_accounts), requires_sub_accounts_reorder: requires_sub_accounts_reorder}
  end

end
