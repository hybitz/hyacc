module Reports
  class WithholdingSummary
    attr_accessor :calendar_year
    attr_accessor :company
    attr_accessor :total_salary #支払金額
    attr_accessor :withholding_tax #源泉徴収税額
    attr_accessor :total_salary_include_previous #支払金額(前職を含む)
    attr_accessor :withholding_tax_include_previous #源泉徴収税額(前職を含む)
  end
end
