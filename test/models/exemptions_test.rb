require 'test_helper'

class ExemptionsTest < ActiveSupport::TestCase

  def test_fiscal_year_for_december_of_calendar_year_期首が7月以降
    company = Company.first
    assert company.start_month_of_fiscal_year >= 7
    exemptions = Exemption.where(company_id: company.id)
    assert_equal [2008, 2007],  [exemptions[0].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[0].yyyy]
    assert_equal [2009, 2008],  [exemptions[1].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[1].yyyy]
    assert_equal [2010, 2009],  [exemptions[2].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[2].yyyy]
  end

  def test_fiscal_year_for_december_of_calendar_year_期首が6月以前
    company = Company.second
    assert company.start_month_of_fiscal_year <= 6
    employee = Employee.find_by(company_id: company.id)
    [2007, 2008, 2009].each do |y|
      Exemption.create!(employee_id: employee.id, company_id: company.id, yyyy: y)
    end
    exemptions = Exemption.where(company_id: company.id)
    assert_equal [2007, 2007], [exemptions[0].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[0].yyyy]
    assert_equal [2008, 2008], [exemptions[1].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[1].yyyy]
    assert_equal [2009, 2009], [exemptions[2].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[2].yyyy]
  end
end
