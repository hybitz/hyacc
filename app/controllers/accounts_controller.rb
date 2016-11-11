class AccountsController < ApplicationController

  # 税抜経理方式の場合は、勘定科目の税区分を取得
  # それ以外は、非課税をデフォルトとする
  def show
    account = Account.get(params[:id])
    tax_type = current_user.company.get_tax_type_for(account) if account

    ret = {:tax_type => tax_type}
    render :json => ret
  end

end
