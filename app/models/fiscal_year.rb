class FiscalYear < ActiveRecord::Base
  include HyaccErrors

  belongs_to :company
  validates_presence_of :company_id, :fiscal_year
  validates_uniqueness_of :fiscal_year, :scope => :company_id

  before_save :reset_carry_forward_journal
  after_save :create_housework
  after_create :create_sequence_for_asset_code

  def get_carry_forward_journal
    journals = JournalHeader.find_closing_journals(self, SLIP_TYPE_CARRY_FORWARD)
    return nil if journals.empty?
    return journals.first if journals.size == 1
    raise HyaccException.new(ERR_DUPLICATEE_CARRY_FORWARD_JOURNAL)
  end

  def get_deemed_tax_journals
    JournalHeader.find_closing_journals(self, SLIP_TYPE_DEEMED_TAX)
  end

  def tax_exclusive?
    self.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
  end

  def carry_status_name
    CARRY_STATUS[ carry_status ]
  end

  def closing_status_name
    CLOSING_STATUS[ closing_status ]
  end

  def consumption_entry_type_name
    CONSUMPTION_ENTRY_TYPES[ consumption_entry_type ]
  end

  def open?
    closing_status == CLOSING_STATUS_OPEN
  end

  def is_closing
    closing_status == CLOSING_STATUS_CLOSING
  end

  def is_closed
    closing_status == CLOSING_STATUS_CLOSED
  end

  def closed?
    closing_status == CLOSING_STATUS_CLOSED
  end

  def is_not_closed
    ! closed?
  end

  def is_carried
    carry_status == CARRY_STATUS_CARRIED
  end

  def is_not_carried
    ! is_carried
  end

  # 期首の年月を取得
  def start_year_month
    ret = HyaccDateUtil.get_start_year_month_of_fiscal_year( fiscal_year, company.start_month_of_fiscal_year )

    # 初年度の場合を考慮
    founded_year_month = HyaccDateUtil.to_int(company.founded_date) / 100
    if ret < founded_year_month
      ret = founded_year_month
    end

    ret
  end

  def start_day
    ret = Date.strptime("#{start_year_month}01", '%Y%m%d')
    if ret < company.founded_date
      company.founded_date
    else
      ret
    end
  end

  # 期末の年月を取得
  def end_year_month
    HyaccDateUtil.get_end_year_month_of_fiscal_year( fiscal_year, company.start_month_of_fiscal_year )
  end

  # 期首から期末までの年月を配列で取得
  def year_month_range
    ret = []
    from = start_year_month
    to = end_year_month

    while from <= to
      ret << from
      from = HyaccDateUtil.add_months(from, 1)
    end

    ret
  end

  def tax_management_type_name
    TAX_MANAGEMENT_TYPES[tax_management_type]
  end

  private

  # 個人事業主の場合は家事按分を作成
  def create_housework
    if company.personal?
      hw = Housework.find_by_fiscal_year(fiscal_year)
      unless hw
        hw = Housework.new
        hw.company_id = company.id
        hw.fiscal_year = fiscal_year
        hw.save!
      end
    end
  end

  # 資産コード用のシーケンスを作成
  def create_sequence_for_asset_code
    Sequence.create_sequence(Asset, fiscal_year)
  end

  def reset_carry_forward_journal
    if self.is_not_closed
      # 繰越仕訳があれば削除
      jh = self.get_carry_forward_journal
      if jh
        raise HyaccException.new(ERR_DB) unless jh.destroy
      end

      self.carry_status = CARRY_STATUS_NOT_CARRIED
      self.carried_at = nil
    end
  end
end
