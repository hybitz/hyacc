class TaxFinder < Base::Finder
  include HyaccConstants

  attr_accessor :include_has_tax
  attr_accessor :include_nontaxable
  attr_accessor :include_checked
  
  def setup_from_params( params )
    super(params)
    
    return unless params

    @include_has_tax = params[:include_has_tax].to_i
    @include_nontaxable = params[:include_nontaxable].to_i
    @include_checked = params[:include_checked].to_i
  end
  
  def list
    JournalHeader.where(conditions).includes(:journal_details).joins(:tax_admin_info).order('ym desc, day desc, journal_headers.created_at desc').reverse
  end

  def count
    JournalHeader.where(conditions).joins(:tax_admin_info).count
  end

  protected

  # 検索条件を作成する
  def conditions
    sql = SqlBuilder.new
    
    # 年月
    sql.append "ym >= ? and ym <= ?",
        HyaccDateUtil.get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year ),
        HyaccDateUtil.get_end_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    
    # 伝票区分
    sql.append "and slip_type in (?, ?, ?)",
        SLIP_TYPE_SIMPLIFIED,
        SLIP_TYPE_TRANSFER,
        SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION

    # 検索キー
    sql.append "and finder_key rlike ?",
        JournalUtil.build_rlike_condition( nil, 0, branch_id )

    # 消費税を含む伝票も含むかどうか
    unless include_has_tax.to_i == 1
      sql.append "and finder_key not rlike ? and finder_key not rlike ?",
          JournalUtil.build_rlike_condition( ACCOUNT_CODE_TEMP_PAY_TAX, 0, 0 ),
          JournalUtil.build_rlike_condition( ACCOUNT_CODE_SUSPENSE_TAX_RECEIVED, 0, 0 )
    end

    # 非課税のみで構成されている伝票も含むかどうか
    if include_nontaxable.to_i == 1
      sql.append "and should_include_tax = ?", false
    else
      sql.append "and should_include_tax = ?", true
    end
    
    # 確認フラグ
    if include_checked.to_i == 1
      sql.append "and checked = ?", true
    else
      sql.append "and checked = ?", false
    end
    
    sql.to_a
  end

end
