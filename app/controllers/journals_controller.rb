class JournalsController < Base::HyaccController
  include JournalHelper
  include JournalUtil
  include AssetUtil

  view_attribute :title => '振替伝票'
  view_attribute :finder, :class => JournalFinder, :only => :index

  before_action :setup_view_attributes, :only => ['index', 'new', 'show', 'edit', 'add_detail']

  # 添付されている領収書を削除状態にする
  def delete_receipt
    @journal_header = JournalHeader.find(params[:id])
    @journal_header.delete_flag_of_receipt_file = true
    @journal_header.receipt_path = nil
    render :partial => 'form_receipt'
  end

  # 領収書をダウンロードする
  def download_receipt
    jh = JournalHeader.find( params[:id] )
    send_file(File.join(UPLOAD_DIRECTORY, jh.receipt_path))
  end

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
      clear_asset_from_details(@journal)
    else
      @journal = create_new_journal
    end
  end

  def add_detail
    @journal_detail = JournalDetail.new
    render :partial => 'detail_fields', :locals => {:jd => @journal_detail, :index => params[:index]}
  end

  def create
    @journal = Journal.new(journal_params)
    @journal.company_id = current_user.company.id
    @journal.slip_type = decide_slip_type
    @journal.create_user_id = current_user.id
    @journal.update_user_id = current_user.id
    retrieve_details(@journal)

    begin
      @journal.transaction do
        # まずは登録してIDを取得
        @journal.save!

        # 資産チェック
        validate_assets(@journal, nil)

        # 領収書が指定されていれば保存
        unless @journal.receipt_file.nil? or @journal.receipt_file.blank?
          @journal.receipt_path = save_receipt_file(receipt_save_dir(@journal), @journal.receipt_file)
        end

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
      @detail_no = @journal.journal_details.last.detail_no + 1
      render 'new'
    end
  end

  def edit
    @journal = Journal.find(params[:id])
    @detail_no = @journal.journal_details.last.detail_no + 1

    # 編集不可能な伝票区分の場合はエラー
    # ただし、エラーメッセージを表示するのではなく一覧画面に遷移させる
    unless can_edit(@journal)
      redirect_to :action => 'index' and return
    end
  end

  def update
    @journal = Journal.find(params[:id])
    old = @journal.copy

    begin
      @journal.transaction do
        @journal.slip_type = decide_slip_type( old )
        @journal.ym = params[:journal][:ym]
        @journal.day = params[:journal][:day]
        @journal.remarks = params[:journal][:remarks]
        @journal.delete_flag_of_receipt_file = params[:journal][:delete_flag_of_receipt_file]
        @journal.receipt_file = params[:journal][:receipt_file]
        @journal.lock_version = params[:journal][:lock_version]
        @journal.update_user_id = current_user.id
        retrieve_details(@journal)

        # 資産チェック
        validate_assets(@journal, old)

        # 削除フラグが立っている場合、ファイルを物理削除
        if @journal.receipt_path.present?
          if @journal.delete_flag_of_receipt_file
            delete_upload_file(@journal.receipt_path)
            @journal.receipt_path = nil
          end
        end

        # 領収書が指定されていれば保存
        if @journal.receipt_file.present?
          @journal.receipt_path = save_receipt_file(receipt_save_dir(@journal), @journal.receipt_file)
        end

        # 自動仕訳を作成
        do_auto_transfers(@journal)

        # 仕訳チェック
        validate_journal(@journal, old)

        # 登録        
        @journal.save!
      end

      flash[:notice] = '伝票を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      setup_view_attributes
      @detail_no = @journal.journal_details.last.detail_no + 1
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
    params.require(:journal).permit(:ym, :day, :slip_type, :remarks, :amount,
        :delete_flag_of_receipt_file, :receipt_path, :lock_version, :fiscal_year_id, :company_id)
  end

  def create_new_journal
    default_account = @frequencies.size > 0 ? Account.get(@frequencies[0].input_value.to_i) : @accounts[0]

    ret = Journal.new
    ret.ym = @ym
    ret.day = @day

    ret.journal_details << JournalDetail.new
    ret.journal_details[0].detail_no = 1
    ret.journal_details[0].dc_type = DC_TYPE_DEBIT
    ret.journal_details[0].account_id = default_account.id

    ret.journal_details << JournalDetail.new
    ret.journal_details[1].detail_no = 2
    ret.journal_details[1].dc_type = DC_TYPE_CREDIT
    ret.journal_details[1].account_id = default_account.id

    ret
  end

  # 伝票区分を決定する
  # 新規登録時（更新前の仕訳がnil）の場合は一般振替
  # 更新前の仕訳が
  # ・簡易入力の場合は一般振替
  # ・一般振替の場合は一般振替
  # ・台帳登録の場合は台帳登録
  # ・それ以外の場合はエラー
  def decide_slip_type( old_journal = nil )
    return SLIP_TYPE_TRANSFER if old_journal.nil?
    return SLIP_TYPE_TRANSFER if old_journal.slip_type == SLIP_TYPE_SIMPLIFIED
    return old_journal.slip_type if [SLIP_TYPE_TRANSFER, SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION].include? old_journal.slip_type

    raise HyaccException.new(ERR_INVALID_SLIP_TYPE)
  end

  def create_or_update_asset(detail)
    # 固定資産の場合は資産を設定
    a = Account.get(detail.account_id)
    if a.depreciable
      asset = Asset.find(detail.asset_id.to_i) if detail.asset_id.to_i > 0
      unless asset
        asset = Asset.new
        asset.code = create_asset_code(current_user.company.get_fiscal_year_int(@journal_header.ym))
        asset.name = detail.note.empty? ? @journal_header.remarks : detail.note
        asset.status = ASSET_STATUS_CREATED
        asset.depreciation_method = a.depreciation_method
        asset.depreciation_limit = 1 # 平成19年度以降は1年まで償却可能
      end
      asset.account_id = detail.account_id
      asset.sub_account_id = detail.sub_account_id
      asset.branch_id = detail.branch_id
      asset.ym = @journal_header.ym
      asset.day = @journal_header.day
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
    
    if account.path.include? ACCOUNT_CODE_INVESTMENT
      investment = Investment.find(detail.investment_id.to_i) if detail.investment_id.to_i > 0
      unless investment
        investment = Investment.new
        investment.shares = detail.shares
      end 
    else
      detail.asset = nil
    end
  end


  def retrieve_details(jh)
    # 明細が存在しない場合はエラー
    raise HyaccException.new unless params[:journal_details]

    new_details = []
    params[:journal_details].each do |key, value|
      id = value[:id].to_i
      detail = nil
      if id > 0
        jh.journal_details.each do |jd|
          if jd.id == id
            detail = jd
            break
          end
        end
      end
      detail = update_detail_attributes(detail, value)
      detail.journal_header = jh

      if detail.tax_type == TAX_TYPE_INCLUSIVE
        detail.amount = detail.input_amount.to_i - detail.tax_amount.to_i
        HyaccLogger.debug("内税なので、入力金額[#{detail.input_amount}]から消費税額[#{detail.tax_amount}]を引いた額を本体金額[#{detail.amount}]とします。")
      else
        detail.amount = detail.input_amount.to_i
      end

      create_or_update_asset(detail)
      new_details << detail

      # 税抜経理方式で消費税があれば、消費税明細を自動仕訳
      if detail.tax_amount.to_i > 0
        tax_detail = JournalDetail.new
        tax_detail.detail_no = nil # 画面で必要としないため、DB登録時に決定する
        tax_detail.detail_type = DETAIL_TYPE_TAX
        tax_detail.dc_type = detail.dc_type
        tax_detail.tax_type = TAX_TYPE_NONTAXABLE

        account = Account.get(detail.account_id)

        # 借方の場合は仮払消費税
        if account.dc_type == DC_TYPE_DEBIT
          tax_detail.account_id = Account.get_by_code( ACCOUNT_CODE_TEMP_PAY_TAX ).id
        # 貸方の場合は借受消費税
        elsif account.dc_type == DC_TYPE_CREDIT
          tax_detail.account_id = Account.get_by_code( ACCOUNT_CODE_SUSPENSE_TAX_RECEIVED ).id
        end

        tax_detail.branch_id = detail.branch_id
        tax_detail.amount = detail.tax_amount.to_i

        # 対象の明細との関連を設定
        tax_detail.main_journal_detail = detail
        tax_detail.journal_header = jh
        new_details << tax_detail
      end
    end

    set_detail_no( new_details )
    jh.journal_details = new_details
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
