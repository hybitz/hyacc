require 'test_helper'

class FiscalYearTest < ActiveSupport::TestCase

  def test_create
    assert FiscalYear.where(company_id: 3, fiscal_year: 2011).present?

    fy = FiscalYear.new(company_id: 3, fiscal_year: 2011)
    assert fy.invalid?
    assert_raise(ActiveRecord::RecordNotUnique) do
      fy.save(validate: false)
    end
  end
  
  def test_validates_uniqueness_of
    assert_not_nil FiscalYear.find_by_company_id_and_fiscal_year(3, 2011)
    assert_raise(ActiveRecord::RecordInvalid) {
      FiscalYear.new(:company_id=>3, :fiscal_year=>2011).save!
    }
  end
  
  def test_year_month_range
    c = Company.find(2)

    # 初年度は9月開始
    fy = c.founded_fiscal_year
    range = fy.year_month_range
    assert_equal 7, range.size
    assert_equal 200609, range[0]
    assert_equal 200703, range[6]
    
    # 翌年度以降は年間12ヶ月
    fy = c.current_fiscal_year
    range = fy.year_month_range
    assert_equal 12, range.size
    assert_equal 200704, range[0]
    assert_equal 200803, range[11]
  end

  def test_start_day
    company.founded_date = '2015-03-10'
    company.start_month_of_fiscal_year = 4

    fy = FiscalYear.new(company: company, fiscal_year: 2014)
    assert_equal '2015-03-10', fy.start_day.strftime('%Y-%m-%d')

    fy = FiscalYear.new(company: company, fiscal_year: 2015)
    assert_equal '2015-04-01', fy.start_day.strftime('%Y-%m-%d')
  end

end
