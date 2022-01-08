class Journal < ApplicationRecord
  include HyaccErrors
  include JournalDate

  belongs_to :company
  belongs_to :depreciation, inverse_of: 'journals', optional: true
  belongs_to :payroll, optional: true

  has_many :journal_details, inverse_of: 'journal', dependent: :destroy
  accepts_nested_attributes_for :journal_details, allow_destroy: true

  has_many :transfer_journals, :foreign_key => :transfer_from_id, # 外部キーは所有される側にあるので、fromとしている
    :class_name => 'Journal', dependent: :destroy
  accepts_nested_attributes_for :transfer_journals

  has_one :tax_admin_info, dependent: :destroy
  accepts_nested_attributes_for :tax_admin_info

  validates_presence_of :company_id, :ym, :day, :remarks
  validates_format_of :ym, :with => /[0-9]{6}/ # TODO 月をもっと正確にチェック
  validates_with JournalValidator

  has_one :receipt, -> { where deleted: false }, inverse_of: 'journal'
  accepts_nested_attributes_for :receipt,
      :reject_if => proc {|attrs| attrs['id'].blank? && attrs['file'].blank? && attrs['file_cache'].blank? }

  before_save :update_sum_info, :set_update_user_id
  after_save :update_tax_admin_info

  def self.find_closing_journals(fiscal_year, slip_type)
    where(company_id: fiscal_year.company_id, slip_type: slip_type).where('ym >= ? and ym <= ?', fiscal_year.start_year_month, fiscal_year.end_year_month)
  end

  def create_user_name
    @create_user ||= User.find_by_id(create_user_id)
    @create_user && @create_user.name
  end

  def update_user_name
    @update_user ||= User.find_by_id(update_user_id)
    @update_user && @update_user.name
  end

  def get_normal_detail_count
    journal_details.inject( 0 ){| count, jd|
      jd.normal_detail? ? count + 1 : count
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

  # 自動振替伝票が存在するか
  def has_auto_transfers
      return true if transfer_journals.size > 0
      journal_details.each do |jd|
        return true if jd.has_auto_transfers
    end

    false
  end

  # 伝票と伝票に紐付いているすべての自動振替伝票をリストアップ
  def get_all_related_journals
    ret = []
    ret << self

    journal_details.each do |jd|
      jd.transfer_journals.each do |tj|
        ret += tj.get_all_related_journals
      end
    end

    transfer_journals.each do |tj|
      ret += tj.get_all_related_journals
    end

    ret
  end

  # 通常明細に消費税明細をマージして返す
  # 自動振替伝票が関連している場合は、それもマージして返す
  def normal_details
    return @normal_details if @normal_details

    @normal_details = []
    journal_details.each do |jd|
      next unless jd.normal_detail?

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

  def save_with_tax!
    old = Journal.find(self.id) if self.persisted?

    journal_details.each do |detail|
      next unless detail.normal_detail?

      case detail.tax_type
      when TAX_TYPE_INCLUSIVE
        detail.amount = detail.input_amount.to_i - detail.tax_amount.to_i
      else
        detail.amount = detail.input_amount.to_i
      end

      # 税抜経理方式で消費税があれば、消費税明細を自動仕訳
      if detail.tax_amount.to_i > 0
        tax_detail = journal_details.find{|jd| jd.persisted? and jd.main_detail_id == detail.id }
        tax_detail ||= journal_details.build(:main_detail => detail)
        tax_detail.detail_type = DETAIL_TYPE_TAX
        tax_detail.dc_type = detail.dc_type
        tax_detail.tax_type = TAX_TYPE_NONTAXABLE

        case detail.account.dc_type
        when DC_TYPE_DEBIT
          # 借方の場合は仮払消費税
          tax_detail.account = Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX)
        when DC_TYPE_CREDIT
          # 貸方の場合は借受消費税
          tax_detail.account = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_TAX_RECEIVED)
        end

        tax_detail.branch = detail.branch
        tax_detail.amount = detail.tax_amount.to_i
      end
    end

    journal_details.each do |detail|
      next if detail.normal_detail?
      next if detail.new_record?

      main_detail = journal_details.find{|jd| jd.id == detail.main_detail_id }
      if main_detail.tax_type_nontaxable?
        detail.mark_for_destruction
      end
    end

    # 明細番号を付与
    set_detail_no

    # 資産チェック
    AssetUtil.validate_assets(self, old)

    # 自動仕訳を作成
    Auto::AutoJournalUtil.do_auto_transfers(self)

    # 仕訳チェック
    JournalUtil.validate_journal(self, old)

    save!
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
    company.get_fiscal_year(self.ym)
  end

  def copy
    copy = Journal.new
    copy.attributes = self.attributes
    copy.id = nil

    self.journal_details.each do |src_jd|
      jd = copy.journal_details.build(src_jd.attributes.except('id', 'created_at', 'updated_at'))

      if src_jd.asset
        jd.asset = Asset.new
        jd.asset.attributes = src_jd.asset.attributes
      end

      src_jd.transfer_journals.each do |tj|
        jd.transfer_journals << tj.copy
      end
    end

    # Trac#171 2010/01/27
    # 本体明細に消費税明細への参照を設定する
    self.journal_details.each do |src_jd|
      if src_jd.tax_detail.present?
        copy_jd = copy.journal_detail(src_jd.detail_no)
        copy_jd.tax_detail = copy.journal_detail(src_jd.tax_detail.detail_no)
      end
    end

    self.transfer_journals.each do |tj|
      copy.transfer_journals << tj.copy
    end

    copy
  end

  def get_credit_amount(account_code, sub_account_code = nil)
    amount = 0
    account = Account.find_by_code(account_code)
    sub_account = account.get_sub_account_by_code(sub_account_code) if sub_account_code
    journal_details.each do | jd |
      if jd.dc_type == DC_TYPE_CREDIT && jd.account_id == account.id
        if sub_account_code.nil? || jd.sub_account_id == sub_account.id
          amount += jd.amount
        end
      end
    end
    amount
  end

  def get_debit_amount(account_code, sub_account_code = nil)
    amount = 0
    account = Account.find_by_code(account_code)
    sub_account = account.get_sub_account_by_code(sub_account_code) if sub_account_code
    journal_details.each do | jd |
      if jd.dc_type == DC_TYPE_DEBIT && jd.account_id == account.id
        if sub_account_code.nil? || jd.sub_account_id == sub_account.id
          amount += jd.amount
        end
      end
    end
    amount
  end
  
  private

  def set_detail_no
    detail_no = 1
    journal_details.each do |jd|
      next if jd.deleted?
      jd.detail_no = detail_no
      detail_no += 1
    end
  end

  # 伝票の合計金額を取得する
  # 借方のみ集計する
  def update_amount
    amount_debit = 0
    amount_credit = 0

    journal_details.each do |jd|
      next if jd.deleted?

      case jd.dc_type
      when DC_TYPE_DEBIT
        amount_debit += jd.amount
      when DC_TYPE_CREDIT
        amount_credit += jd.amount
      else
        raise HyaccException.new(ERR_INVALID_DC_TYPE)
      end
    end

    if amount_debit != amount_credit
      HyaccLogger.error ERR_DC_AMOUNT_NOT_THE_SAME + "　借方[#{amount_debit}]　貸方[#{amount_credit}] #{self.to_yaml}"
      raise HyaccException.new( ERR_DC_AMOUNT_NOT_THE_SAME )
    end

    if amount_debit == 0
      raise '合計金額が 0 円です。'
    end

    self.amount = amount_debit
  end

  # 明細に含まれる勘定科目、補助科目、計上部門から伝票検索キーを作成
  def update_finder_key
    key = '-'
    journal_details.each do |jd|
      next if jd.deleted?

      key << jd.account.code << ','

      # 補助科目は指定なしの場合がある
      unless jd.sub_account_id.nil?
        key << jd.sub_account_id.to_s
      end
      key << ','
      key << jd.branch.id.to_s
      key << '-'
    end

    self.finder_key = key
  end

  def set_update_user_id
    self.update_user_id ||= self.create_user_id
  end
end
