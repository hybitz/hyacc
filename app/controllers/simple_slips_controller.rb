class SimpleSlipsController < Base::HyaccController
  before_action :preload_account
  before_action :check_sub_accounts
  view_attribute :finder, :class => Slips::SlipFinder, :include_params => :account_code

  # 勘定科目ごとの詳細入力部分を取得する
  def get_account_details
    @simple_slip = new_slip

    renderer = AccountDetails::AccountDetailRenderer.get_instance(params[:account_id])
    if renderer
      render :partial => renderer.get_template(controller_name)
    else
      render :nothing => true
    end
  end

  def get_templates
    my_account = Account.get_by_code(finder.account_code)
    @simple_slip = SimpleSlip.new(:my_account_id => my_account.id)

    like = '%' + JournalUtil.escape_search(params[:query]) + '%'
    query = 'account_id <> ? and (keywords like ? or remarks like ?) and deleted=?', my_account.id, like, like, false
    templates = SimpleSlipTemplate.where(query)

    json = '['
    templates.each_with_index do |t, index|
      if t.account_id.to_i > 0
        account = Account.get(t.account_id)
        renderer = AccountDetails::AccountDetailRenderer.get_instance(account.id)
        if renderer
          account_detail = render_to_string(:partial => renderer.get_template(controller_name), :formats => [:html])
          HyaccLogger.debug account_detail
        end

        # テンプレートが画面の対象としている科目と同じ貸借区分であれば金額は減少側にセット
        if my_account.dc_type == account.dc_type
          increase_or_decrease = account.dc_type == t.dc_type ? "decrease" : "increase"
        # テンプレートが画面の対象としている科目と異なる貸借区分であれば金額は増加側にセット
        elsif my_account.dc_type == account.opposite_dc_type
          increase_or_decrease = account.dc_type == t.dc_type ? "increase" : "decrease"
        end
      end

      # 税抜経理方式でなければ、消費税は非課税として扱う
      tax_type = get_tax_type_for_current_fy(t.tax_type)
      if tax_type == TAX_TYPE_NONTAXABLE
        tax_amount = nil
      else
        tax_amount = t.tax_amount
      end

      # 金額が０円の場合は、空白にする（そのほうが入力が楽）
      amount = t.amount.to_i > 0 ? t.amount.to_s : ''

      json << ',' if index > 0
      json << <<-"JSON"
        {
          "label":"#{t.remarks}",
          "remarks":"#{t.remarks}",
          "account_id":"#{account.id.to_s}",
          "account_code":"#{account.code}",
          "account_name":"#{account.name}",
          "sub_account_id":"#{t.sub_account_id.to_s}",
          "branch_id":"#{t.branch_id.to_s}",
          "increase_or_decrease":"#{increase_or_decrease}",
          "amount":"#{amount}",
          "tax_type":"#{tax_type.to_s}",
          "tax_amount":"#{tax_amount.to_s}",
          "focus_on_complete":"#{t.focus_on_complete.to_s}",
          "sub_accounts":#{account.sub_accounts.collect{|sa| sa = {:id=>sa.id, :name=>sa.name}}.to_json},
          "account_detail":#{account_detail ? account_detail.to_json : '""'}
        }
      JSON
    end
    json << ']'

    render :json => json
  end

  def index
    setup_view_attributes
    @simple_slip ||= setup_new_slip

    # 登録済み伝票を検索
    @slips = finder.list(:per_page => current_user.slips_per_page)

    # 表示伝票直前までの累計金額、現在の累計金額の取得
    if @slips.empty?
      @pre_sum_amount = @sum_amount = 0
    else
      @pre_sum_amount = finder.get_net_sum_until(@slips.first)
      @sum_amount = finder.get_net_sum
    end

    render :index
  end

  def show
    setup_view_attributes
    @simple_slip = finder.find(params[:id])
  end

  def create
    @simple_slip = SimpleSlip.new(simple_slip_params)

    begin
      ActiveRecord::Base.transaction do
        @simple_slip.save!

        # 年月日を入力状態を保存
        save_ymd_input_state(@simple_slip)

        # 選択した勘定科目をカウント
        save_input_frequencies(@simple_slip)
      end

      flash[:notice] = '伝票を登録しました。'
      redirect_to :action => :index, :account_code => @simple_slip.my_account.code
    rescue => e
      handle(e)
      index
    end
  end

  def edit
    setup_view_attributes
    @simple_slip = finder.find(params[:id])
  end

  def update
    @simple_slip = finder.find(params[:id])
    @simple_slip.attributes = simple_slip_params

    begin
      ActiveRecord::Base.transaction do
        @simple_slip.save!

        # 年月日を入力状態を保存
        save_ymd_input_state(@simple_slip)
      end

      flash[:notice] = '伝票を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      setup_view_attributes
      render 'edit'
    end
  end

  def destroy
    @simple_slip = finder.find(params[:id])
    @simple_slip.lock_version = params[:lock_version]

    begin
      ActiveRecord::Base.transaction do
        if @simple_slip.destroy
          flash[:notice] = '伝票を削除しました。'
        end
      end
    rescue => e
      handle(e)
    end

    # 正常終了でもエラーでもリストへ戻る
    redirect_to :action => :index
  end

  def copy
    @simple_slip = finder.find(params[:id])
    account = Account.get(@simple_slip.account_id)

    renderer = AccountDetails::AccountDetailRenderer.get_instance(account.id)
    if renderer
      account_detail = render_to_string(:partial => renderer.get_template(controller_name))
    end

    @json = {
      :remarks => @simple_slip.remarks,
      :account_id => @simple_slip.account_id,
      :sub_account_id => @simple_slip.sub_account_id,
      :branch_id => @simple_slip.branch_id,
      :amount_increase => @simple_slip.amount_increase,
      :amount_decrease => @simple_slip.amount_decrease,
      :tax_type => get_tax_type_for_current_fy(@simple_slip.tax_type),
      :sub_accounts => account.sub_accounts.collect{|sa| sa = {:id => sa.id, :name => sa.name}},
      :account_detail => account_detail,
      :tax_amount_increase => @simple_slip.tax_amount_increase,
      :tax_amount_decrease => @simple_slip.tax_amount_decrease
    }

    render :json => @json
  end

  private

  def default_url_options
    {
      :account_code => params[:account_code]
    }
  end

  def simple_slip_params
    permitted = [
      :my_sub_account_id,
      :ym, :day, :remarks,
      :account_id, :sub_account_id, :branch_id,
      :amount_increase, :amount_decrease,
      :tax_type, :tax_rate_percent, :tax_amount_increase, :tax_amount_decrease,
      :auto_journal_type, :auto_journal_year, :auto_journal_month, :auto_journal_day,
      :social_expense_number_of_people, :settlement_type,
      :asset_id, :asset_lock_version,
      :lock_version
    ]

    ret = params.require(:simple_slip).permit(*permitted).merge(:my_account_id => @account.id)

    case action_name
    when 'create'
      ret = ret.merge(:create_user_id => current_user.id, :company_id => current_user.company_id)
    when 'update'
      ret = ret.merge(:update_user_id => current_user.id)
      ret[:auto_journal_type] ||= nil
    end

    ret
  end

  # 補助科目が必須の場合でまだ補助科目が存在しない場合はマスタメンテに誘導する
  def check_sub_accounts
    @account = Account.get_by_code(params[:account_code])
    unless @account.sub_account_type == SUB_ACCOUNT_TYPE_NORMAL
      unless @account.has_sub_accounts
        render :action=>:sub_accounts_required and return
      end
    end
  end

  def new_slip(hash = {})
    SimpleSlip.new(hash.merge(:my_account_id => @account.id))
  end

  def save_input_frequencies(slip)
    InputFrequency.save_input_frequency(current_user.id, INPUT_TYPE_SIMPLE_SLIP_ACCOUNT_ID, slip.account_id)
  end

  def save_ymd_input_state(simple_slip)
    ymd = session[:ymd_input_state]
    if ymd.nil?
      ymd = Slips::YmdInputState.new
      session[:ymd_input_state] = ymd
    end
    ymd.ym = simple_slip.ym
    ymd.day = simple_slip.day
  end

  def setup_new_slip
    ymd = session[:ymd_input_state]
    if ymd.nil?
      today = Date.today
      ymd = Slips::YmdInputState.new
      ymd.ym = today.strftime("%Y%m")
      ymd.day = today.strftime("%d")
      session[:ymd_input_state] = ymd
    end

    ret = new_slip
    ret.ym = ymd.ym
    ret.day = ymd.day

    account = @frequencies.present? ? Account.get(@frequencies.first.input_value) : @accounts.first
    ret.account_id = account.id
    ret.tax_type = current_user.company.get_tax_type_for(account)

    ret.branch_id = @finder.branch_id
    ret
  end

  # この簡易入力が対象としている科目
  def preload_account
    @account = Account.get_by_code(params[:account_code])
  end

  def setup_view_attributes
    # 勘定科目選択用リスト
    # 自身と同じ勘定科目は選択させない（貸借のどちらか一方に限定）
    @accounts = Account.get_journalizable_accounts.select{|a| a.id != @account.id }

    # 勘定科目の利用頻度
    @frequencies = InputFrequency.where(:user_id => current_user.id, :input_type => INPUT_TYPE_SIMPLE_SLIP_ACCOUNT_ID)
        .order('frequency desc').limit(current_user.account_count_of_frequencies)

    # 部門選択用リスト
    @branches = get_branches
  end

  # 現在の会計年度としてふさわしい消費税区分を取得する
  # 税抜経理方式でなければ、消費税は非課税として扱う
  def get_tax_type_for_current_fy( tax_type )
    unless current_user.company.current_fiscal_year.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
      return TAX_TYPE_NONTAXABLE
    end

    tax_type
  end
end
