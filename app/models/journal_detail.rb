class JournalDetail < ApplicationRecord
  include HyaccConstants
  include HyaccErrors

  attr_accessor :input_amount
  attr_accessor :tax_amount

  # 自動振替用の入力フィールド
  attr_accessor :auto_journal_type
  attr_accessor :auto_journal_year
  attr_accessor :auto_journal_month
  attr_accessor :auto_journal_day

  # 有価証券用の入力フィールド
  attr_accessor :investment_id

  belongs_to :journal_header, :inverse_of => 'journal_details'

  has_one :asset, :dependent => :destroy
  accepts_nested_attributes_for :asset

  has_one :investment, :dependent => :destroy
  accepts_nested_attributes_for :investment

  has_one :tax_detail, :foreign_key => :main_detail_id, :class_name => 'JournalDetail', :dependent => :destroy
  belongs_to :main_detail, :class_name => 'JournalDetail'

  has_many :transfer_journals, :foreign_key => :transfer_from_detail_id, :class_name => 'JournalHeader', :dependent => :destroy
  accepts_nested_attributes_for :transfer_journals

  validates :account_id, :presence => true
  validate :validate_account_and_sub_account
  validates_with Validators::SubAccountPresenceValidator
  validates :branch_id, :presence => true
  validates_format_of :social_expense_number_of_people, :with => /[0-9]{0,3}/
  validates_format_of :settlement_type, :with => /[0-9]{0,1}/
  validates :amount, :presence => true
  validates_with Validators::TaxRateValidator

  before_save :set_asset
  before_save :update_names
  before_save :normalize_tax_rate

  def deleted?
    marked_for_destruction?
  end

  def account
    account_id ? Account.get(self.account_id) : nil
  end

  def account=(account)
    self.account_id = account ? account.id : nil
  end

  def branch
    Branch.get(self.branch_id)
  end

  def branch=(branch)
    self.branch_id = branch ? branch.id : nil
  end

  def dc_type_name
    DC_TYPES[ dc_type ]
  end

  def tax_type_name
    TAX_TYPES[ tax_type ]
  end

  def debit_amount
    self.dc_type == DC_TYPE_DEBIT ? self.amount : 0
  end

  def credit_amount
    self.dc_type == DC_TYPE_CREDIT ? self.amount : 0
  end

  def tax_rate_percent
    return self.tax_rate unless self.tax_rate.present?
    (self.tax_rate.to_f * 100.0).to_i
  end

  def tax_rate_percent=(value)
    if value.present?
      self.tax_rate = value.to_f / 100.0
    else
      self.tax_rate = value
    end
  end

  def tax_type_nontaxable?
    self.tax_type.to_i == TAX_TYPE_NONTAXABLE
  end

  # 自動振替日付を取得します
  def auto_journal_date
    begin
      return Date.new( auto_journal_year.to_i, auto_journal_month.to_i, auto_journal_day.to_i )
    rescue Exception
      return nil
    end
  end

  def auto_journal_type
    @auto_journal_type.to_i
  end

  # 伝票明細に関連しているすべての自動仕訳の自動仕訳区分を取得する
  def auto_journal_types
    ret = []
    ret << auto_journal_type if auto_journal_type > 0
    ret << AUTO_JOURNAL_TYPE_ALLOCATED_COST if is_allocated_cost
    ret << AUTO_JOURNAL_TYPE_ALLOCATED_ASSETS if is_allocated_assets
    ret
  end

  # 自動振替伝票が存在するか
  def has_auto_transfers
    transfer_journals.size > 0
  end

  def normal_detail?
    detail_type == DETAIL_TYPE_NORMAL
  end

  def tax_detail?
    detail_type == DETAIL_TYPE_TAX
  end

  def sub_account
    # 勘定科目が未設定の場合はnilを返す
    return nil unless account
    # 補助科目IDが未設定の場合はnilを返す
    return nil if sub_account_id.to_i == 0

    return account.get_sub_account_by_id(sub_account_id)
  end

  # マスタの名称を明細自身に設定する
  def update_names
    self.account_name = account.name
    self.sub_account_name = sub_account ? sub_account.name : nil
    self.branch_name = branch.name
  end

  def validate_account_and_sub_account
    return unless account

    # 仕訳登録可能な勘定科目かどうか
    unless account.journalizable
      logger.warn ERR_NOT_JOURNALIZABLE_ACCOUNT + " account_id=#{account_id}"
      errors.add(:account, ERR_NOT_JOURNALIZABLE_ACCOUNT)
    end

    # 接待交際費の飲食の場合は人数必須
    if account.sub_account_type == SUB_ACCOUNT_TYPE_SOCIAL_EXPENSE
      if SubAccount.find(sub_account_id).social_expense_number_of_people_required
        if social_expense_number_of_people.to_i == 0
          errors.add(:social_expense_number_of_people, :blank)
        end
      end
    end

    # 法人税等の場合は決算区分必須
    if account.is_corporate_tax
      if settlement_type.to_i == 0
        errors.add(:settlement_type, ERR_REQUIRED_SETTLEMENT_TYPE)
      end
    end
  end

  private

  def set_asset
    return unless dc_type == DC_TYPE_DEBIT

    asset = self.asset

    # 固定資産の場合は資産を設定
    if account.depreciable
      unless asset
        asset = build_asset
        asset.code = AssetUtil.create_asset_code(journal_header.company.get_fiscal_year_int(journal_header.ym))
        asset.name = note.present? ? note : journal_header.remarks
        asset.status = ASSET_STATUS_CREATED
        asset.depreciation_method = account.depreciation_method
        asset.depreciation_limit = 1 # 平成19年度以降は1年まで償却可能
      end
      asset.account = account
      asset.sub_account_id = sub_account_id
      asset.branch = branch
      asset.ym = journal_header.ym
      asset.day = journal_header.day
      asset.amount = amount
    else
      asset.mark_for_destruction if asset
    end
  end

  def normalize_tax_rate
    self.tax_rate = self.tax_rate.to_f
  end

end
