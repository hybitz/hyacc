class JournalsController < Base::HyaccController
  include JournalHelper
  include JournalUtil
  include AssetUtil

  view_attribute :title => '振替伝票'
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
      render :nothing => true
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
      @journal.ym = @ym
      @journal.day = @day
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
        # まずは登録してIDを取得
        @journal.save_with_tax!

        # 資産チェック
        validate_assets(@journal, nil)

        # 自動仕訳を作成
        do_auto_transfers(@journal)

        # 仕訳チェック
        validate_journal(@journal)

        # 登録
        @journal.save!
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
        # まずは更新
        @journal.save_with_tax!

        # 資産チェック
        validate_assets(@journal, old)

        # 自動仕訳を作成
        do_auto_transfers(@journal)

        # 仕訳チェック
        validate_journal(@journal, old)

        # 更新
        @journal.save!
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
      selected_account = Account.get(params[:account_id])
      fy = current_user.company.current_fiscal_year
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
          validate_assets(nil, jh)

          # 仕訳チェック
          validate_closing_status_on_delete(jh)

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
    redirect_to :action => 'index'
  end

  def get_allocation
    jd = JournalDetail.new(:dc_type => params[:dc_type],
            :account_id => params[:account_id], :branch_id => params[:branch_id],
            :is_allocated_cost => true, :is_allocated_assets => false)
    render :partial => 'get_allocation', :locals => {:jd => jd, :index => params[:index]}
  end

  private

  def journal_params
    permitted = [
      :ym, :day, :remarks, :amount, :lock_version, :fiscal_year_id,
      :journal_details_attributes => [
          :id, :_destroy, :dc_type, :account_id, :branch_id, :sub_account_id,
          :input_amount, :tax_type, :tax_rate_percent, :tax_amount,
          :social_expense_number_of_people, :note,
          :is_allocated_cost, :is_allocated_assets, :settlement_type, :shares,
          :auto_journal_type, :auto_journal_year, :auto_journal_month, :auto_journal_day,
          :asset_attributes => [:id, :lock_version]
      ],
      :receipt_attributes => [:id, :deleted, :original_filename, :file, :file_cache]
    ]

    ret = params.require(:journal).permit(*permitted)
    ret = ret.merge(:company_id => current_user.company_id, :update_user_id => current_user.id)

    case action_name
    when 'create'
      ret = ret.merge(:slip_type => SLIP_TYPE_TRANSFER, :create_user_id => current_user.id)
    end

    ret
  end

  def new_journal
    default_account = @frequencies.size > 0 ? Account.get(@frequencies.first.input_value.to_i) : @accounts.first

    ret = Journal.new
    ret.ym = @ym
    ret.day = @day
    ret.journal_details.build(:dc_type => DC_TYPE_DEBIT, :account_id => default_account.id)
    ret.journal_details.build(:dc_type => DC_TYPE_CREDIT, :account_id => default_account.id)
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

  def create_or_update_asset(detail)
    # 固定資産の場合は資産を設定
    a = Account.get(detail.account_id)
    if a.depreciable
      asset = Asset.find(detail.asset_id.to_i) if detail.asset_id.to_i > 0
      unless asset
        asset = Asset.new
        asset.code = AssetUtil.create_asset_code(current_user.company.get_fiscal_year_int(@journal.ym))
        asset.name = detail.note.empty? ? @journal.remarks : detail.note
        asset.status = ASSET_STATUS_CREATED
        asset.depreciation_method = a.depreciation_method
        asset.depreciation_limit = 1 # 平成19年度以降は1年まで償却可能
      end
      asset.account_id = detail.account_id
      asset.sub_account_id = detail.sub_account_id
      asset.branch_id = detail.branch_id
      asset.ym = @journal.ym
      asset.day = @journal.day
      asset.amount = detail.amount
      asset.lock_version = detail.asset_lock_version.to_i
      detail.asset = asset
    else
      detail.asset = nil
    end
  end

  def create_or_update_inventment(detail)
    # 有価証券の場合は有価証券情報を設定
    a = Account.get(detail.account_id)

    if account.path.include? ACCOUNT_CODE_SECURITIES
      investment = Investment.find(detail.investment_id.to_i) if detail.investment_id.to_i > 0
      unless investment
        investment = Investment.new
        investment.shares = detail.shares
      end
    else
      detail.asset = nil
    end
  end

  def save_input_frequencies(jh)
    jh.normal_details.each do |jd|
      InputFrequency.save_input_frequency(jh.create_user_id, INPUT_TYPE_JOURNAL_ACCOUNT_ID, jd.account_id)
    end
  end

  def setup_view_attributes
    # 今月の取得
    now = Time.now
    @ym = now.strftime("%Y%m")
    @day = now.strftime("%d")

    # 勘定科目選択用リスト
    @accounts = get_accounts

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
