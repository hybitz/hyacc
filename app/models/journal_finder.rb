class JournalFinder < Base::Finder
  include HyaccConstants

  attr_accessor :slip_type_selection
  attr_accessor :remarks

  def initialize(user)
    super(user)
    @slip_type_selection = 1
    @remarks = nil
  end
  
  def setup_from_params( params )
    return unless params
    
    super(params)
    @slip_type_selection = params[:slip_type_selection].to_i
    @remarks = params[:remarks]
  end

  def list(options = {})
    per_page = options[:per_page] || @slips_per_page

    conditions = make_conditions
    
    # 初期検索でページングしていない時は一番最後（直近）のページを表示する
    if @page == 0
      total_count = JournalHeader.where(conditions).count
      if total_count > 0
        @page = total_count / per_page + (total_count % per_page > 0 ? 1 : 0)

      end

      @page = 1 if @page == 0
    end
    
    # 伝票を取得
    JournalHeader.paginate(
      :conditions => conditions,
      :order => "ym, day, created_on",
      :page => @page,
      :per_page => per_page)
  end

  private

  def get_slip_types
    case @slip_type_selection
    when 1
      return [SLIP_TYPE_TRANSFER]
    when 2
      return [SLIP_TYPE_TRANSFER, SLIP_TYPE_SIMPLIFIED]
    when 3
      return [SLIP_TYPE_TRANSFER, SLIP_TYPE_SIMPLIFIED, SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION]
    else
      raise '予期していない処理分岐です'
    end
  end

  def make_conditions
    sql = SqlBuilder.new
    sql.append('deleted = ?', false)
    
    # 伝票区分
    if @slip_type_selection != 4
      sql.append('and slip_type in (' + get_slip_types.join(', ') + ')')
    end
    
    # 年月
    normalized_ym = @ym.to_s.split('-').join
    if normalized_ym.to_i > 0
      sql.append('and ym like ?', "#{normalized_ym}%")
    end

    # 勘定科目または部門
    if @account_id > 0 or @branch_id > 0
      account_code = @account_id > 0 ? Account.get(@account_id).code : 0
      sql.append('and finder_key rlike ?', JournalUtil.finder_key_rlike(account_code, 0, @branch_id))
    end

    # 摘要
    if @remarks.present?
      sql.append('and remarks like ?', '%' + JournalUtil.escape_search(@remarks) + '%')
    end

    sql.to_a
  end

end
