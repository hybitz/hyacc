class SimpleSlip
  include ActiveModel::Model
  include HyaccConstants
  include HyaccErrors

  attr_accessor :id, :company_id, :lock_version
  attr_accessor :my_account_id, :my_sub_account_id
  attr_accessor :create_user_id, :update_user_id
  attr_accessor :ym, :day, :remarks
  attr_accessor :account_id, :sub_account_id, :branch_id
  attr_accessor :amount_increase, :amount_decrease, :slip_amount_increase, :slip_amount_decrease
  attr_accessor :tax_type, :tax_rate_percent, :tax_amount_increase, :tax_amount_decrease
  attr_accessor :auto_journal_type, :auto_journal_year, :auto_journal_month, :auto_journal_day
  attr_accessor :asset_id, :asset_code, :asset_lock_version
  attr_accessor :social_expense_number_of_people, :settlement_type

  validates :my_account_id, :presence => true
  validates_with Validators::MySubAccountPresenceValidator
  validates :ym, :presence => true
  validates :day, :presence => true
  validates :remarks, :presence => true
  validates :account_id, :presence => true
  validates_with Validators::UniqueAccountValidator
  validates_with Validators::SubAccountPresenceValidator

  def self.build_from_journal(my_account_id, id)
    ret = SimpleSlip.new(:my_account_id => my_account_id, :id => id)

    if ret.editable?
      ret.load_journal
    else
      raise HyaccException.new(ERR_INVALID_SLIP)
    end

    ret
  end

  def attributes=(attrs = {})
    attrs.each do |key, value|
      self.__send__("#{key}=", value)
    end
  end

  def save!
    raise ActiveRecord::RecordInvalid.new(self) unless valid?

    build_journal
    journal.save_with_tax!

    self.id = journal.id
  end

  def destroy
    # 締め状態の確認
    JournalUtil.validate_closing_status_on_delete(journal)

    # 資産チェック
    AssetUtil.validate_assets(nil, journal)

    journal.lock_version = lock_version.to_i
    journal.destroy
  end

  # 簡易入力機能で編集可能かどうか
  def editable?
    Slips::SlipUtils.editable_as_simple_slip(journal, my_account_id)
  end

  def persisted?
    id.present?
  end

  def new_record?
    ! persisted?
  end

  def my_account
    Account.find(my_account_id)
  end

  def account
    Account.find(account_id)
  end

  def sub_account
    account.sub_accounts.find{|sa| sa.id == sub_account_id } if sub_account_id
  end

  def sub_accounts
    account ? HyaccUtil.sort(account.sub_accounts.map{|sa| [sa.name, sa.id] }, :code) : []
  end

  def branch
    Branch.find(branch_id)
  end

  def amount
    amount_increase.to_i > 0 ? amount_increase.to_i : amount_decrease.to_i
  end

  def tax_amount
    tax_amount_increase.to_i > 0 ? tax_amount_increase.to_i : tax_amount_decrease.to_i
  end

  def tax_type_name
    TAX_TYPES[tax_type]
  end
  
  def nontaxable?
    tax_type == TAX_TYPE_NONTAXABLE
  end

  def auto_journal_type
    @auto_journal_type.to_i
  end

  def has_auto_transfers
    journal.has_auto_transfers
  end

  def has_accrued_expense_transfers
    journals = journal.get_all_related_journals
    return false if journals.size != 3
    return false if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
    return false if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
    true
  end

  def has_date_input_expense_transfers
    journals = journal.get_all_related_journals
    return false if journals.size != 3
    return false if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_EXPENSE
    return false if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_EXPENSE
    true
  end

  def has_prepaid_expense_transfers
    journals = journal.get_all_related_journals
    return false if journals.size != 3
    return false if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
    return false if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
    true
  end

  def load_journal
    self.ym = journal.ym
    self.day = journal.day
    self.remarks = journal.remarks
    self.lock_version = journal.lock_version
    self.create_user_id = journal.create_user_id
    self.update_user_id = journal.update_user_id

    if has_prepaid_expense_transfers
      self.auto_journal_type = AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
    elsif has_accrued_expense_transfers
      self.auto_journal_type = AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
    elsif has_date_input_expense_transfers
      self.auto_journal_type = AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE

      journals = journal.get_all_related_journals
      if journals[0].date != journals[1].date
        self.auto_journal_year = journals[1].date.year
        self.auto_journal_month = journals[1].date.month
        self.auto_journal_day = journals[1].date.day
      else
        self.auto_journal_year = journals[2].date.year
        self.auto_journal_month = journals[2].date.month
        self.auto_journal_day = journals[2].date.day
      end
    end

    # 本伝票が前提としている科目側の明細を取得
    my_detail = journal.normal_details.find{|jd| jd.account_id == self.my_account_id }
    self.my_sub_account_id = my_detail.sub_account_id

    # ユーザ入力科目側の明細を取得
    target_detail = journal.normal_details.find{|jd| jd.account_id != self.my_account_id }
    self.account_id = target_detail.account_id
    self.branch_id = target_detail.branch_id
    self.sub_account_id = target_detail.sub_account_id
    self.tax_type = target_detail.tax_type
    self.tax_rate_percent = target_detail.tax_rate_percent

    # 金額、消費税額
    if my_detail.dc_type == my_detail.account.dc_type
      self.amount_increase = target_detail.input_amount
      self.tax_amount_increase = target_detail.tax_amount
      self.slip_amount_increase = target_detail.input_amount
      self.amount_decrease = nil
      self.tax_amount_decrease = nil
      self.slip_amount_decrease = nil
    else
      self.amount_increase = nil
      self.tax_amount_increase = nil
      self.slip_amount_increase = nil
      self.amount_decrease = target_detail.input_amount
      self.tax_amount_decrease = target_detail.tax_amount
      self.slip_amount_decrease = target_detail.input_amount
    end

    # 接待交際費の参加人数
    self.social_expense_number_of_people = target_detail.social_expense_number_of_people

    # 法人税の決算区分
    self.settlement_type = target_detail.settlement_type

    # 固定資産の場合は資産コード、資産名をVOにセットする
    if target_detail.asset
      self.asset_id = target_detail.asset.id
      self.asset_code = target_detail.asset.code
      self.asset_lock_version = target_detail.asset.lock_version
    end
  end

  private

  def journal
    if @journal.nil?
      @journal = JournalHeader.find(id) if id.present?
      @journal ||= JournalHeader.new
    end

    @journal
  end

  # 仕訳明細の作成
  def build_journal
    journal.company_id = company_id if company_id.present?
    journal.slip_type = SLIP_TYPE_SIMPLIFIED
    journal.ym = ym
    journal.day = day
    journal.remarks = remarks
    journal.lock_version = lock_version if lock_version.present?
    journal.create_user_id = create_user_id if journal.new_record?
    journal.update_user_id = update_user_id if journal.persisted?

    # この簡易入力が扱っている科目
    jd1 = journal.normal_details.find{|jd| jd.account_id == my_account.id }
    jd1 ||= journal.journal_details.build
    jd1.account = my_account
    jd1.dc_type = amount_increase.to_i > 0 ? my_account.dc_type : my_account.opposite_dc_type
    jd1.tax_type = TAX_TYPE_NONTAXABLE
    jd1.tax_rate_percent = 0
    jd1.branch_id = branch_id
    jd1.sub_account_id = my_sub_account_id
    if tax_type.to_i == TAX_TYPE_EXCLUSIVE
      jd1.input_amount = amount + tax_amount
      jd1.tax_amount = 0
    else
      jd1.input_amount = amount
      jd1.tax_amount = 0
    end

    # 入力された科目
    jd2 = journal.normal_details.find{|jd| jd.account_id != my_account.id }
    jd2 ||= journal.journal_details.build
    jd2.account = account
    jd2.dc_type = amount_increase.to_i > 0 ? my_account.opposite_dc_type : my_account.dc_type
    jd2.tax_type = tax_type
    jd2.tax_rate_percent = tax_rate_percent
    jd2.branch_id = branch_id
    jd2.sub_account_id = sub_account_id
    jd2.input_amount = amount
    jd2.tax_amount = tax_amount

    # 計上日振替の設定
    jd2.auto_journal_type = auto_journal_type
    jd2.auto_journal_year = auto_journal_year
    jd2.auto_journal_month = auto_journal_month
    jd2.auto_journal_day = auto_journal_day

    # 接待交際費の参加人数
    jd2.social_expense_number_of_people = account.is_social_expense ? social_expense_number_of_people : nil

    # 法人税の決算区分
    jd2.settlement_type = account.is_corporate_tax ? settlement_type : nil

    # 資産の楽観ロック
    # TODO asset_id の使い道は？
    jd2.asset.lock_version = asset_lock_version if jd2.asset
  end

end
