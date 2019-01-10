class FiscalYear < ApplicationRecord
  include HyaccErrors

  belongs_to :company
  validates_presence_of :company_id, :fiscal_year
  validates_uniqueness_of :fiscal_year, scope: :company_id

  after_create :create_sequence_for_asset_code

  # 期
  def fiscal_period
    fiscal_year - company.founded_fiscal_year.fiscal_year + 1
  end
  
  def get_deemed_tax_journals
    Journal.find_closing_journals(self, SLIP_TYPE_DEEMED_TAX)
  end

  def tax_exclusive?
    self.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
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

  def closing?
    closing_status == CLOSING_STATUS_CLOSING
  end

  def closed?
    closing_status == CLOSING_STATUS_CLOSED
  end

  # 期首の年月を取得
  def start_year_month
    ret = HyaccDateUtil.get_start_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year)

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

  # 中間決算期の年月
  def first_half_end_year_month
    ym = (Date.strptime("#{end_year_month}01", '%Y%m%d') - 6.months)
    ym.year * 100 + ym.month
  end

  # 期末の年月
  def end_year_month
    HyaccDateUtil.get_end_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year)
  end

  def end_day
    Date.strptime("#{end_year_month}01", '%Y%m%d').end_of_month
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

  # 資産コード用のシーケンスを作成
  def create_sequence_for_asset_code
    Sequence.create_sequence(Asset, fiscal_year)
  end

end
