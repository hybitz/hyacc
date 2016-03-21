class JournalHeader < ActiveRecord::Base
  include HyaccUtil

  belongs_to :depreciation

  has_many :journal_details, :inverse_of => 'journal_header', :dependent => :destroy
  accepts_nested_attributes_for :journal_details

  has_many :transfer_journals, :foreign_key => :transfer_from_id, # 外部キーは所有される側にあるので、fromとしている
    :class_name => 'JournalHeader', :dependent => :destroy
  accepts_nested_attributes_for :transfer_journals

  has_one :tax_admin_info, :dependent => :destroy
  accepts_nested_attributes_for :tax_admin_info

  before_save :update_sum_info
  after_save :update_tax_admin_info
  
  validates_presence_of :company_id, :ym, :day, :remarks
  validates_format_of :ym, :with => /[0-9]{6}/ # TODO 月をもっと正確にチェック
  validates_with JournalValidator

  has_one :receipt, -> { where :deleted => false }, :inverse_of => 'journal_header'
  accepts_nested_attributes_for :receipt,
      :reject_if => proc {|attrs| attrs['id'].blank? && attrs['file'].blank? && attrs['file_cache'].blank? }

  def self.find_closing_journals(fiscal_year, slip_type)
    where(:company_id => fiscal_year.company_id, :fiscal_year_id => fiscal_year.id, :slip_type => slip_type)
  end

  # 伝票の年月日を取得
  def date
    Date.new( year, month, day )
  end
  
  def month
    ym % 100
  end
  
  def get_normal_detail_count
    journal_details.inject( 0 ){| count, jd|
      jd.detail_type == DETAIL_TYPE_NORMAL ? count + 1 : count
    }
  end
  
  def journal_detail(detail_no)
    journal_details.each do |detail|
      return detail if detail.detail_no.to_i == detail_no.to_i
    end
  end

  # 同一会計年度かどうか
  def is_same_fiscal_year( other )
    self.fiscal_year == other.fiscal_year
  end
  
  def year
    ym / 100
  end

  # 自動振替伝票が存在するか
  def has_auto_transfers
      return true if transfer_journals.size > 0
      journal_details.each do |jd|
        return true if jd.has_auto_transfers
    end

    false
  end
  
  # 通常明細に消費税明細をマージして返す
  # 自動振替伝票が関連している場合は、それもマージして返す
  def normal_details
    return @normal_details if @normal_details
    
    @normal_details = []
    journal_details.each do |jd|
      next unless jd.detail_type == DETAIL_TYPE_NORMAL

      # 入力金額がない場合は、DBから読み込んだ時のはず
      if jd.input_amount.nil?
        jd.input_amount = jd.amount
  
        # 金額を消費税明細から計算
        if jd.tax_detail
          case jd.tax_type
          when TAX_TYPE_INCLUSIVE
            jd.input_amount += jd.tax_detail.amount
            jd.tax_amount = jd.tax_detail.amount
          when TAX_TYPE_EXCLUSIVE
            jd.tax_amount = jd.tax_detail.amount
          end
        end
        
        # 計上日振替がされているかチェック
        if jd.has_auto_transfers
          jd.transfer_journals.each do |tj|
            case tj.slip_type
            when SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
              jd.auto_journal_type = AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
            when SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
              jd.auto_journal_type = AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
            when SLIP_TYPE_AUTO_TRANSFER_EXPENSE
              jd.auto_journal_type = AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE
              jd.auto_journal_year = tj.year
              jd.auto_journal_month = tj.month
              jd.auto_journal_day = tj.day
            end
          end
        end
      end
      
      @normal_details << jd
    end
    @normal_details
  end
  
  # 伝票区分名称
  def slip_type_name
    SLIP_TYPES[ slip_type ]
  end
  
  # 明細の集計情報を更新する
  def update_sum_info
    update_amount
    update_finder_key
  end
  
  # 消費税管理情報を更新する
  # 伝票を登録、更新する際には必ず消費税管理情報を初期化する
  def update_tax_admin_info
    if fiscal_year.tax_management_type != TAX_MANAGEMENT_TYPE_EXCLUSIVE
      self.tax_admin_info = nil
      return
    end

    should_include_tax = false
    journal_details.each do |jd|
      if jd.account.tax_type != TAX_TYPE_NONTAXABLE
        should_include_tax = true
        break
      end
    end
    
    self.tax_admin_info = TaxAdminInfo.new unless self.tax_admin_info
    self.tax_admin_info.should_include_tax = should_include_tax
    self.tax_admin_info.checked = 0
  end

  def fiscal_year
    user = User.find(update_user_id)
    user.company.get_fiscal_year(self.ym)
  end

  def copy
    self.class.copy_journal(self)
  end

  def self.copy_journal(jh)
    copy = Journal.new
    copy.attributes = jh.attributes
    copy.id = nil

    jh.journal_details.each do |src_jd|
      jd = JournalDetail.new
      jd.attributes = src_jd.attributes

      if src_jd.asset
        jd.asset = Asset.new
        jd.asset.attributes = src_jd.asset.attributes
      end

      src_jd.transfer_journals.each do |tj|
        jd.transfer_journals << tj.copy
      end
      
      copy.journal_details << jd
    end
    
    # Trac#171 2010/01/27
    # 本体明細に消費税明細への参照を設定する
    jh.journal_details.each do |src_jd|
      if src_jd.tax_detail.present?
        copy_jd = copy.journal_detail(src_jd.detail_no) 
        copy_jd.tax_detail = copy.journal_detail(src_jd.tax_detail.detail_no)
      end
    end

    jh.transfer_journals.each do |tj|
      copy.transfer_journals << tj.copy
    end

    copy
  end
  
  private

  # 伝票の合計金額を取得する
  # 借方のみ集計する
  def update_amount
    amount_debit = 0
    amount_credit = 0
    
    HyaccLogger.debug "伝票金額集計 ID[#{id}]"
    journal_details.each do |jd|
      HyaccLogger.debug "　　#{DC_TYPES[jd.dc_type]}:#{TAX_TYPES[jd.tax_type]}:#{jd.amount}"

      if jd.dc_type == DC_TYPE_DEBIT
        amount_debit += jd.amount
      elsif jd.dc_type = DC_TYPE_CREDIT
        amount_credit += jd.amount
      else
        raise HyaccException.new( ERR_INVALID_DC_TYPE )
      end
    end
    
    if amount_debit != amount_credit
      HyaccLogger.error ERR_DC_AMOUNT_NOT_THE_SAME + "　借方[#{amount_debit}]　貸方[#{amount_credit}]"
      raise HyaccException.new( ERR_DC_AMOUNT_NOT_THE_SAME )
    end
    
    self.amount = amount_debit
  end
  
  # 明細に含まれる勘定科目、補助科目、計上部門から伝票検索キーを作成
  def update_finder_key
    key = '-'
    journal_details.each{ |jd|
      key << jd.account.code << ','
      
      # 補助科目は指定なしの場合がある
      unless jd.sub_account_id.nil?
        key << jd.sub_account_id.to_s
      end
      key << ','
      key << jd.branch.id.to_s
      key << '-'
    }
    
    self.finder_key = key
  end  
end
