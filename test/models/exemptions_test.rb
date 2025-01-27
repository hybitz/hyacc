require 'test_helper'

class ExemptionsTest < ActiveSupport::TestCase
  def test_fiscal_year_including_december_of_yyyy_期首が7月以降
    company = Company.first
    assert_equal 12, company.start_month_of_fiscal_year
    exemptions = Exemption.where(company_id: company.id)
    assert_equal "|2008|2007|",  "|" + [exemptions[0].fiscal_year_including_december_of_yyyy.fiscal_year, exemptions[0].yyyy].join("|") + "|"
    assert_equal "|2009|2008|",  "|" + [exemptions[1].fiscal_year_including_december_of_yyyy.fiscal_year, exemptions[1].yyyy].join("|") + "|"
    assert_equal "|2010|2009|",  "|" + [exemptions[2].fiscal_year_including_december_of_yyyy.fiscal_year, exemptions[2].yyyy].join("|") + "|"
  end

  def test_fiscal_year_including_december_of_yyyy_期首が6月以前
    company = Company.second
    assert_equal 4, company.start_month_of_fiscal_year
    employee = Employee.find_by(company_id: company.id)
    [2007,2008,2009].each do |y|
      Exemption.create!(employee_id: employee.id, company_id: company.id, yyyy: y)
    end
    exemptions = Exemption.where(company_id: company.id)
    assert_equal "|2007|2007|",  "|" + [exemptions[0].fiscal_year_including_december_of_yyyy.fiscal_year, exemptions[0].yyyy].join("|") + "|"
    assert_equal "|2008|2008|",  "|" + [exemptions[1].fiscal_year_including_december_of_yyyy.fiscal_year, exemptions[1].yyyy].join("|") + "|"
    assert_equal "|2009|2009|",  "|" + [exemptions[2].fiscal_year_including_december_of_yyyy.fiscal_year, exemptions[2].yyyy].join("|") + "|"
  end
end
