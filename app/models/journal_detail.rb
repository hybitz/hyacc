class JournalDetail < ActiveRecord::Base
  include HyaccConstants
  include HyaccErrors

  attr_accessor :receipt_file
  attr_accessor :input_amount
  attr_accessor :tax_amount
  
  # 資産管理用の入力フィールド
  attr_accessor :asset_id
  attr_accessor :asset_code
  attr_accessor :asset_lock_version
  
  # 自動振替用の入力フィールド
  attr_accessor :auto_journal_type
  attr_accessor :auto_journal_year
  attr_accessor :auto_journal_month
  attr_accessor :auto_journal_day

  has_one :asset, :dependent=>:destroy
  has_one :tax_journal_detail, :foreign_key=>:main_detail_id, :class_name=>"JournalDetail", :dependent=>:destroy
  belongs_to :main_journal_detail, :foreign_key=>:main_detail_id, :class_name=>"JournalDetail"
  has_many :transfer_journals, :foreign_key=>:transfer_from_detail_id, :class_name=>"JournalHeader", :dependent=>:destroy

  belongs_to :journal_header
  
  accepts_nested_attributes_for :asset
  accepts_nested_attributes_for :transfer_journals

  validates :account_id, :presence => true
  validates :branch_id, :presence => true
  validate :validate_account_and_sub_account
  validates_format_of :social_expense_number_of_people, :with => /[0-9]{0,3}/
  validates_format_of :settlement_type, :with => /[0-9]{0,1}/
  validates :amount, :presence => true
  validates_with Validators::TaxRateValidator

  before_save :update_names
  before_save :normalize_tax_rate
  
  def account
    Account.get(self.account_id)
  end

  def branch
    Branch.get(self.branch_id)
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
    self.tax_type.to_i == HyaccConstants::TAX_TYPE_NONTAXABLE
  end

  # 自動振替日付を取得します
  def auto_journal_date
    begin
      return Date.new( auto_journal_year.to_i, auto_journal_month.to_i, auto_journal_day.to_i )
    rescue Exception
      return nil
    end
  end
      
  # 伝票明細に関連しているすべての自動仕訳の自動仕訳区分を取得する
  def auto_journal_types
    ret = []
    ret << @auto_journal_type if @auto_journal_type.to_i > 0
    ret << AUTO_JOURNAL_TYPE_ALLOCATED_COST if is_allocated_cost
    ret << AUTO_JOURNAL_TYPE_ALLOCATED_ASSETS if is_allocated_assets
    ret
  end
  
  # 自動振替伝票が存在するか
  def has_auto_transfers
    transfer_journals.size > 0
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

    # 補助科目を持つ勘定科目の場合は補助科目の指定が必須
    if account.sub_accounts.present?
      if sub_account_id.to_i == 0
        errors[:sub_account] = I18n.t('errors.messages.empty')
      end
    end
    
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

  def normalize_tax_rate
    self.tax_rate = self.tax_rate.to_f
  end

end
