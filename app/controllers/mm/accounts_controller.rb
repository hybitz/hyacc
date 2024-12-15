class Mm::AccountsController < Base::HyaccController
  helper_method :finder

  def index
    @accounts = finder.list
    session[:current_list_action] = action_name
  end

  def list_tree
    @accounts = Account.where('parent_id is null and code != ?', ACCOUNT_CODE_VARIOUS).order(:display_order)
    session[:current_list_action] = action_name
  end

  # 勘定科目の階層構造を更新する
  def update_tree
    moved = Account.find(params[:moved])
    target = Account.find(params[:target])
    position = params[:position]

    Account.transaction do
      if position == 'inside'
        Account.where('parent_id = ?', target.id).update_all('display_order = display_order + 1')
        moved.update!(:display_order => 0, :parent_id => target.id)
      elsif position == 'after'
        Account.where('parent_id = ? and display_order > ?', target.parent_id, target.display_order).update_all('display_order = display_order + 1')
        moved.update!(:display_order => target.display_order + 1, :parent_id => target.parent_id)
      end
    end

    head :ok
  end

  def show
    @account = Account.find(params[:id])
  end

  def add_sub_account
    sa = SubAccount.new
    render :partial => 'sub_account_fields', :locals => {:sub_account => sa, :index => params[:index]}
  end

  def new
    parent = Account.find(params[:parent_id])
    @account = Account.new(parent_id: parent.id, dc_type: parent.dc_type, account_type: parent.account_type)
  end

  def create
    @account = Account.new(account_params)

    begin
      @account.transaction do
        @account.save!
        update_sub_accounts
      end

      flash[:notice] = '勘定科目を追加しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :action => 'new'
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])

    begin
      @account.transaction do
        sub_account_type_old = @account.sub_account_type
        @account.update!(account_params)
        check_sub_account_type_editable(@account, sub_account_type_old)
        update_sub_accounts
      end

      flash[:notice] = '勘定科目を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :action => 'edit'
    end
  end

  def destroy
    @account = load_account

    # システム必須の勘定科目は削除不可
    if @account.system_required?
      raise HyaccException.new(ERR_SYSTEM_REQUIRED_ACCOUNT) and return
    end

    # 既に伝票が起票されていた場合は削除不可
    if is_already_used(@account)
      raise HyaccException.new(ERR_ACCOUNT_ALREADY_USED) and return
    end

    @account.update!(deleted: true)
    render 'common/reload'
  end

  private

  def finder
    unless @finder
      @finder = AccountFinder.new(finder_params)
    end

    @finder
  end

  def finder_params
    if params[:finder].present?
      params.require(:finder).permit(:account_type, :leaf_only)
    else
      {}
    end
  end

  def account_params
    permitted = [
      :name, :dc_type, :account_type, :tax_type,
      :description, :short_description, :trade_type, :is_settlement_report_account,
      :depreciation_method, :is_trade_account_payable, :journalizable,
      :depreciable, :is_tax_account, :sub_account_type
    ]

    ret = params.require(:account)

    case action_name
    when 'create'
      ret = ret.permit(permitted, :code, :parent_id, :sub_account_type)
    when 'update'
      ret = ret.permit(permitted)
    end

    ret
  end

  def check_sub_account_type_editable(account, sub_account_type_old)
    # 変更されていなければ何も問題ない
    return if account.sub_account_type == sub_account_type_old

    # 既に伝票が起票されていた場合は補助科目区分の変更不可
    # ただし、通常の補助科目の設定でまだ補助科目がマスタ登録されていない（ようするにデフォルト状態）場合は変更可
    if is_already_used(account)
      unless is_normal_sub_account_without_sub_accounts(@account)
        raise HyaccException.new(ERR_CANNOT_CHANGE_SUB_ACCOUNT_TYPE)
      end
    end
  end

  def is_already_used(account)
    JournalDetail.where(:account_id => account).present?
  end

  def is_normal_sub_account_without_sub_accounts(account)
    SubAccount.where(:account_id => account).present?
  end

  def load_account
    account = Account.find(params[:id])
    if account.nil? or account.deleted
      raise HyaccException.new( ERR_RECORD_NOT_FOUND )
    end

    account
  end

  # 補助科目を更新する
  # コードの更新はできない
  def update_sub_accounts
    # 通常の補助科目を使用しない場合は何もしない
    return unless @account.has_normal_sub_accounts

    # 更新対象の補助科目を取得
    new_sub_accounts = []
    if params[:sub_accounts]
      params[:sub_accounts].each do |key, values|
        next if values[:id].blank? and values[:code].blank? and values[:name].blank?

        sa = SubAccount.find(values[:id]) if values[:id].present?
        sa ||= SubAccount.new(:account => @account)
        sa.code = values[:code]
        sa.name = values[:name]
        sa.deleted = values[:deleted]
        new_sub_accounts << sa
      end
    end

    @account.sub_accounts_all.each do |sa|
      unless new_sub_accounts.detect{|nsa| sa.id == nsa.id }
        # 既に伝票が起票されていた場合はエラー
        if JournalDetail.where(:account_id => @account.id, :sub_account_id => sa.id).present?
          raise HyaccException.new(ERR_SUB_ACCOUNT_ALREADY_USED)
        end

        # 伝票が存在しなければ削除
        unless sa.destroy
          raise HyaccException.new(ERR_DB)
        end
      end
    end

    @account.sub_accounts_all = new_sub_accounts
    raise ActiveRecord::RecordInvalid.new(@account) if @account.invalid?

    @account.sub_accounts_all.each do |sa|
      sa.save!
    end

  end
end
