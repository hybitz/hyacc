require 'test_helper'

class FiscalYearTest < ActiveSupport::TestCase

  def test_create
    assert FiscalYear.where(:company_id => 3, :fiscal_year => 2011).present?

    fy = FiscalYear.new(:company_id => 3, :fiscal_year => 2011)
    assert fy.invalid?
    assert_raise(ActiveRecord::RecordNotUnique) {
      fy.save(:validate => false)
    }
  end
  
  def test_validates_uniqueness_of
    assert_not_nil FiscalYear.find_by_company_id_and_fiscal_year(3, 2011)
    assert_raise(ActiveRecord::RecordInvalid) {
      FiscalYear.new(:company_id=>3, :fiscal_year=>2011).save!
    }
  end
  
  def test_year_month_range
    # 初年度は9月開始
    fy = FiscalYear.find(5)
    range = fy.year_month_range
    assert_equal 7, range.size
    assert_equal 200609, range[0]
    assert_equal 200703, range[6]
    
    # 翌年度以降は年間12ヶ月
    fy = FiscalYear.find(6)
    range = fy.year_month_range
    assert_equal 12, range.size
    assert_equal 200704, range[0]
    assert_equal 200803, range[11]
  end
end
