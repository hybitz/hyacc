class SimpleSlipController < Base::HyaccController
  before_filter :check_sub_accounts
  view_attribute :finder, :class => Slips::SlipFinder, :include_params => :account_code

  # 添付されている領収書を削除状態にする
  def delete_receipt
    @slip = finder.find(params[:id])
    @slip.delete_flag_of_receipt_file = true
    @slip.receipt_path = nil
    render :partial=>'form_receipt'
  end
  
  # 領収書をダウンロードする
  def download_receipt
    slip = finder.find( params[:id] )
    send_file(UPLOAD_DIRECTORY + "/" + slip.journal_header.receipt_path)
  end
  
  # 勘定科目ごとの詳細入力部分を取得する
  def get_account_details
    id = params[:id].to_i
    @slip = finder.find( id ) if id > 0
    
    renderer = AccountDetails::AccountDetailRenderer.get_instance( params[:account_id] )
    if renderer
      render :partial=>renderer.get_template(controller_name)
    else
      render :text=>''
    end
  end
  
  def get_templates
    @slip = finder.find(params[:id]) if params[:id].to_i > 0
    my_account = Account.get_by_code(finder.account_code)

    like = '%' + Daddy::Utils::SqlUtils.escape_search(params[:query]) + '%'
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
        elsif my_account.dc_type == opposite_dc_type( account.dc_type )
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
    
    if HyaccLogger.debug?
      HyaccLogger.debug("json=" + json)
    end

    render :json => json
  end
  
  def index
    list
  end
  
  # 伝票を一覧表示する。
  # 
  # slip : 内部的な画面遷移用に呼び出す場合で、@slipの初期生成を必要と
  #        しない場合は、@slipを引数に指定して呼び出す。
  def list( slip = nil )
    # 新規登録用のVO
    @slip = setup_new_slip unless slip
        
    # 登録済み伝票を検索
    @slips = finder.list(:per_page => current_user.slips_per_page)
    
    # 表示伝票直前までの累計金額、現在の累計金額の取得
    if @slips.empty?
      @pre_sum_amount = @sum_amount = 0
    else
      @pre_sum_amount = finder.get_net_sum_until( @slips.first )
      @sum_amount = finder.get_net_sum()
    end
    
    render_list
  end
  
  def show
    @slip = finder.find( params[:id] )
    setup_view_attributes
  end

  def create
    @slip = new_slip(params[:slip])
    @slip.user = current_user
    
    begin
      @slip.create
      
      # 年月日を入力状態を保存
      save_ymd_input_state
      
      # 選択した勘定科目をカウント
      save_input_frequencies(@slip)
      
      flash[:notice] = '伝票を登録しました。'
      redirect_to :action => :index, :account_code => params[:account_code]
    rescue Exception => e
      handle(e)
      list( @slip )
    end
  end

  def edit
    @slip = finder.find( params[:id] )
    setup_view_attributes
  end
  
  def update
    @slip = finder.find(params[:slip][:id])
    @slip.user = current_user
    
    begin
      params[:slip][:account_code] = params[:account_code]
      @slip.update(params[:slip])

      # 年月日を入力状態を保存
      save_ymd_input_state

      flash[:notice] = '伝票を更新しました。'
      render 'common/reload'

    rescue Exception => e
      handle(e)
      setup_view_attributes
      render 'edit'
    end
  end
  
  # 税区分の選択状態を更新する
  # 税抜経理方式の場合は、勘定科目の税区分を取得
  # それ以外は、非課税をデフォルトとする
  def update_tax_type
    @tax_type = TAX_MANAGEMENT_TYPE_EXEMPT

    fy = current_user.company.current_fiscal_year
    if fy.tax_exclusive?
      account = get_account(params[:account_id])
      @tax_type = account.tax_type if account
    end
    
    render :text => @tax_type
  end

  def destroy
    begin
      slip = finder.find(params[:id])
      slip.lock_version = params[:lock_version]
      if slip.destroy
        flash[:notice] = '伝票を削除しました。'
      end
    rescue Exception => e
      handle(e)
    end

    # 正常終了でもエラーでもリストへ戻る
    redirect_to :action => :index
  end
  
  def new_from_copy
    slip = finder.find( params[:id] )
    account = Account.get(slip.account_id)
    renderer = AccountDetails::AccountDetailRenderer.get_instance(account.id)
    if renderer
      account_detail = render_to_string(:partial => renderer.get_template(controller_name), :formats => ['html'], :handlers => ['erb'])
      HyaccLogger.debug account_detail
    end
    
    @json = <<-"JSON"
      {
        "remarks":"#{slip.remarks}", 
        "account_id":"#{slip.account_id.to_s}",
        "sub_account_id":"#{slip.sub_account_id.to_s}",
        "branch_id":"#{slip.branch_id.to_s}",
        "amount_increase":"#{slip.amount_increase.to_s}",
        "amount_decrease":"#{slip.amount_decrease.to_s}",
        "tax_type":"#{get_tax_type_for_current_fy(slip.tax_type).to_s}",
        "sub_accounts":#{account.sub_accounts.collect{|sa| sa = {:id=>sa.id, :name=>sa.name}}.to_json},
        "account_detail":#{account_detail ? account_detail.to_json : '""'},
        "tax_amount_increase":"#{slip.tax_amount_increase.to_s}",
        "tax_amount_decrease":"#{slip.tax_amount_decrease.to_s}"
       }
    JSON

    HyaccLogger.debug("json=" + @json)
    render :partial=>'new_from_copy'
  end
  
  private

  # 補助科目が必須の場合でまだ補助科目が存在しない場合はマスタメンテに誘導する
  def check_sub_accounts
    @account = Account.get_by_code(params[:account_code])
    unless @account.sub_account_type == SUB_ACCOUNT_TYPE_NORMAL
      unless @account.has_sub_accounts
        render :action=>:sub_accounts_required and return
      end
    end
  end

  def new_slip( hash = {} )
    hash[:account_code] = params[:account_code]
    slip = Slips::Slip.new( hash )
    slip
  end
  
  def render_list
    setup_view_attributes
    render :template=>'simple_slip/list'
  end

  def save_input_frequencies(slip)
    InputFrequency.save_input_frequency(current_user.id, INPUT_TYPE_SIMPLE_SLIP_ACCOUNT_ID, slip.account_id)
  end

  def save_ymd_input_state
    ymd = session[:ymd_input_state]
    if ymd.nil?  
      ymd = Slips::YmdInputState.new
      session[:ymd_input_state] = ymd
    end
    ymd.ym = @slip.ym
    ymd.day = @slip.day
  end

  def setup_new_slip
    ymd = session[:ymd_input_state]
    if ymd.nil?  
      now = Time.now
      ymd = Slips::YmdInputState.new
      ymd.ym = now.strftime("%Y%m")
      ymd.day = now.strftime("%d")
      session[:ymd_input_state] = ymd
    end

    ret = new_slip
    ret.ym = ymd.ym
    ret.day = ymd.day
    ret.branch_id = @finder.branch_id
    ret
  end

  def setup_view_attributes
    # この簡易入力が対象としている科目
    @account = Account.get_by_code( finder.account_code )

    # 勘定科目選択用リスト
    # 自身と同じ勘定科目は選択させない（貸借のどちらか一方に限定するため）
    @accounts = []
    get_accounts.each do |a|
      @accounts << a unless a.id == @account.id
    end

    # 勘定科目の利用頻度
    @frequencies = InputFrequency.where(:user_id => current_user.id, :input_type => INPUT_TYPE_SIMPLE_SLIP_ACCOUNT_ID)
        .order('frequency desc').limit(current_user.account_count_of_frequencies)

    # 補助科目選択用リスト
    @sub_accounts = load_sub_accounts(@slip.account_id)

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
