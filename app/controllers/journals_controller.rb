class JournalsController < Base::HyaccController
  include JournalHelper
  include AssetUtil

  view_attribute :finder, :class => JournalFinder, :only => :index

  before_action :setup_view_attributes, :only => ['index', 'new', 'show', 'edit', 'add_detail']

  # 勘定科目ごとの詳細入力部分を取得する
  def get_account_detail
    jd = JournalDetail.find(params[:detail_id]) if params[:detail_id].present?
    jd ||= JournalDetail.new

    renderer = AccountDetails::AccountDetailRenderer.get_instance(params[:account_id])
    if renderer
      render :partial => renderer.get_template(controller_name), :locals => {:jd => jd, :index => params[:index]}
    else
      head :ok
    end
  end

  def index
    @journal_headers = finder.list(:per_page => current_user.slips_per_page)
  end

  def show
    @journal = Journal.find(params[:id])
  end

  def new
    if params[:copy_id].present?
      @journal = Journal.find(params[:copy_id]).copy
      @journal.ym = ymd_input_state.ym
      @journal.day = ymd_input_state.day
      AssetUtil.clear_asset_from_details(@journal)
    else
      @journal = new_journal
    end
  end

  def add_detail
    jd = new_journal.journal_details.first
    render :partial => 'detail_fields', :locals => {:jd => jd, :index => params[:index]}
  end

  def create
    @journal = Journal.new(journal_params)

    begin
      @journal.transaction do
        @journal.save_with_tax!
      end

      # 選択した勘定科目をカウント
      save_input_frequencies(@journal)

      flash[:notice] = '伝票を登録しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      setup_view_attributes
      render 'new'
    end
  end

  def edit
    @journal = Journal.find(params[:id])

    # 編集不可能な伝票区分の場合はエラー
    # ただし、エラーメッセージを表示するのではなく一覧画面に遷移させる
    unless can_edit(@journal)
      redirect_to :action => 'index' and return
    end
  end

  def update
    @journal = Journal.find(params[:id])
    old = @journal.copy
    @journal.attributes = journal_params
    @journal.slip_type = decide_slip_type(old)

    begin
      @journal.transaction do
        @journal.save_with_tax!
      end

      flash[:notice] = '伝票を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      setup_view_attributes
      render 'edit'
    end
  end

  # 税区分の選択状態を更新する
  # 税抜経理方式の場合は、勘定科目の税区分を取得
  # それ以外は、非課税をデフォルトとする
  def get_tax_type
    tax_type = TAX_MANAGEMENT_TYPE_EXEMPT

    if params[:account_id].present?
      selected_account = Account.find(params[:account_id])
      fy = current_company.current_fiscal_year
      if fy.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
        tax_type = selected_account.tax_type
      end
    end

    render :json => {:tax_type => tax_type}
  end

  def destroy
    jh = JournalHeader.find(params[:id])
    if can_delete(jh)
      begin
        jh.transaction do
          # 資産チェック
          AssetUtil.validate_assets(nil, jh)

          # 仕訳チェック
          JournalUtil.validate_closing_status_on_delete(jh)

          jh.lock_version = params[:lock_version]
          jh.destroy
        end
        flash[:notice] = '伝票を削除しました。'
      rescue => e
        handle(e)
      end
    else
      flash[:notice] = 'この伝票は削除できません。'
      flash[:is_error_message] = true
    end

    # 正常終了でもエラーでもリストへ戻る
    if request.xhr?
      head :ok
    else
      redirect_to :action => 'index'
    end
  end

  def get_allocation
    account = Account.find(params[:account_id])
    branch = current_company.branches.find(params[:branch_id])

    jd = JournalDetail.new(dc_type: params[:dc_type], account_id: account.id, branch_id: branch.id)
    render :partial => 'get_allocation', locals: {jd: jd, index: params[:index]}
  end

  private

  def journal_params
    permitted = [
      :ym, :day, :remarks, :amount, :lock_version, :fiscal_year_id,
      :journal_details_attributes => [
          :id, :_destroy, :dc_type, :account_id, :branch_id, :sub_account_id,
          :input_amount, :tax_type, :tax_rate_percent, :tax_amount,
          :social_expense_number_of_people, :settlement_type, :note, :allocation_type,
          :auto_journal_type, :auto_journal_year, :auto_journal_month, :auto_journal_day,
          :asset_attributes => [:id, :lock_version]
      ],
      :receipt_attributes => [:id, :deleted, :original_filename, :file, :file_cache]
    ]

    ret = params.require(:journal).permit(*permitted)
    ret = ret.merge(company_id: current_company.id, update_user_id: current_user.id)

    case action_name
    when 'create'
      ret = ret.merge(slip_type: SLIP_TYPE_TRANSFER, create_user_id: current_user.id)
    end

    ret
  end

  def new_journal
    default_account = @frequencies.size > 0 ? Account.find(@frequencies.first.input_value.to_i) : @accounts.first

    ret = Journal.new(company_id: current_company.id)
    ret.ym = ymd_input_state.ym
    ret.day = ymd_input_state.day

    [DC_TYPE_DEBIT, DC_TYPE_CREDIT].each do |dc_type|
      ret.journal_details.build(dc_type: dc_type, account: default_account, branch: current_user.employee.default_branch)
    end

    ret
  end

  # 伝票区分を決定する
  # 新規登録時（更新前の仕訳がnil）の場合は一般振替
  # 更新前の仕訳が
  # ・簡易入力の場合は一般振替
  # ・一般振替の場合は一般振替
  # ・台帳登録の場合は台帳登録 ※有価証券は台帳からの登録のみ可
  # ・それ以外の場合はエラー
  def decide_slip_type( old_journal = nil )
    return SLIP_TYPE_TRANSFER if old_journal.nil?
    return SLIP_TYPE_TRANSFER if old_journal.slip_type == SLIP_TYPE_SIMPLIFIED
    return old_journal.slip_type if [SLIP_TYPE_TRANSFER,
                                     SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION].include? old_journal.slip_type

    raise HyaccException.new(ERR_INVALID_SLIP_TYPE)
  end

  def save_input_frequencies(jh)
    jh.normal_details.each do |jd|
      InputFrequency.save_input_frequency(jh.create_user_id, INPUT_TYPE_JOURNAL_ACCOUNT_ID, jd.account_id)
    end
  end

  def setup_view_attributes
    # 勘定科目選択用リスト
    @accounts = Account.get_journalizable_accounts

    # 勘定科目の利用頻度
    @frequencies = InputFrequency.where(:user_id => current_user.id, :input_type => INPUT_TYPE_JOURNAL_ACCOUNT_ID)
        .order('frequency desc').limit(current_user.account_count_of_frequencies)

    # 部門選択用リスト
    @branches = Branch.not_deleted

    # 新規コピーのリンクを表示するかどうか
    @copy_link = false
    if action_name == 'show'
      @copy_link = true
      @copy_link = params[:copy_link] == 'true' unless params[:copy_link].nil?
    end
  end

end
