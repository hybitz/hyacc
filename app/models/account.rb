class Account < ApplicationRecord
  include HyaccConstants
  include HyaccErrors
  include Accounts::SubAccountsSupport

  acts_as_tree :order => 'display_order'

  validates_presence_of :name, :code
  validate :validate_account_type, :validate_dc_type

  validates_with Validators::UniqueSubAccountsValidator

  before_save :update_path

  def self.expenses
    where(:account_type => ACCOUNT_TYPE_EXPENSE)
  end

  # 仕訳可能な勘定科目のみ取得する
  def self.get_journalizable_accounts(with_deleted = false)
    accounts = where(:journalizable => true)
    accounts = accounts.where(:deleted => false) unless with_deleted
    accounts = accounts.where('code <> ?', ACCOUNT_CODE_VARIOUS).order(:code)

    # 補助科目が未整備の勘定科目を除外
    ret = []
    accounts.each do |a|
      next if a.sub_account_type != SUB_ACCOUNT_TYPE_NORMAL && a.sub_accounts.empty?
      ret << a
    end
    ret
  end

  def code_and_name
    self.code + ':' + self.name
  end

  def account_type_name
    ACCOUNT_TYPES[account_type]
  end

  def dc_type_name
    DC_TYPES[dc_type]
  end

  def debit?
    self.dc_type == DC_TYPE_DEBIT
  end

  def credit?
    self.dc_type == DC_TYPE_CREDIT
  end

  # 反対の貸借区分を取得
  def opposite_dc_type
    debit? ? DC_TYPE_CREDIT : DC_TYPE_DEBIT
  end

  def depreciation_method_name
    DEPRECIATION_METHODS[depreciation_method]
  end

  def sub_account_type_name
    SUB_ACCOUNT_TYPES[sub_account_type]
  end

  def tax_type_name
    TAX_TYPES[tax_type]
  end

  def trade_type_name
    TRADE_TYPES[trade_type]
  end

  def external_trade?
    trade_type == TRADE_TYPE_EXTERNAL
  end

  def internal_trade?
    trade_type == TRADE_TYPE_INTERNAL
  end

  def is_leaf
    children.empty?
  end

  def is_leaf_on_settlement_report
    # リーフの場合は、親をチェック
    if is_leaf
      if parent.is_leaf_on_settlement_report
        false
      else
        is_settlement_report_account
      end
    else
      # 子供のうち1つでも決算書科目でなければtrueを返す
      leaf_on_settlement_report = false
      children.each do |child|
        unless child.is_settlement_report_account
          leaf_on_settlement_report = true
        end
      end

      leaf_on_settlement_report
    end
  end

  def is_node
    ! is_leaf
  end

  def node_level
    path.count('/')
  end

  def bs?
    asset? or debt? or capital?
  end

  def pl?
    profit? or expense?
  end

  # 資産かどうか
  def asset?
    account_type == ACCOUNT_TYPE_ASSET
  end

  # 負債かどうか
  def debt?
    account_type == ACCOUNT_TYPE_DEBT
  end

  # 収益かどうか
  def profit?
    account_type == ACCOUNT_TYPE_PROFIT
  end

  # 資本かどうか
  def capital?
    account_type == ACCOUNT_TYPE_CAPITAL
  end

  def expense?
    account_type == ACCOUNT_TYPE_EXPENSE
  end

  # 流動資産の部
  def is_current_assets?
    path.index(ACCOUNT_CODE_CURRENT_ASSETS)
  end

  # 接待交際費かどうか
  def is_social_expense
    path.include? ACCOUNT_CODE_SOCIAL_EXPENSE
  end

  # 法人税かどうか
  def is_corporate_tax
    sub_account_type == SUB_ACCOUNT_TYPE_CORPORATE_TAX
  end

  private

  def validate_account_type
    if parent
      if parent.account_type != self.account_type
        errors.add(:account_type, ERR_INVALID_ACCOUNT_TYPE)
      end
    end
  end

  def validate_dc_type
    if parent
      if parent.dc_type != self.dc_type
        errors.add(:dc_type, ERR_INVALID_DC_TYPE)
      end
    end
  end

  def update_path
    self.path = get_absolute_path( self )
  end

  def get_absolute_path( account )
    ret = '/' + account.code

    if account.parent
      ret = get_absolute_path(account.parent) + ret
    end

    ret
  end
end
