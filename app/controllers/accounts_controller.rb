class AccountsController < ApplicationController

  # 税抜経理方式の場合は、勘定科目の税区分を取得
  # それ以外は、非課税をデフォルトとする
  def show
    account = Account.get(params[:id])

    if account
      tax_type = current_user.company.get_tax_type_for(account)
      sub_accounts = HyaccUtil.sort(account.sub_accounts, params[:order]).collect{|sa| {:id => sa.id, :name => sa.name}}
    end

    render :json => {:tax_type => tax_type, :sub_accounts => Array(sub_accounts)}
  end

end
