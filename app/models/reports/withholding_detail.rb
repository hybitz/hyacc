module Reports
  class WithholdingDetail
    attr_accessor :calendar_year
    attr_accessor :head_business_office
    attr_accessor :employee
    attr_accessor :company
    attr_accessor :total_salary # 支払金額
    attr_accessor :exemption_amount # 控除額金額
    attr_accessor :after_deduction # 控除後金額
    attr_accessor :withholding_tax # 源泉徴収税額
    attr_accessor :mortgage_deduction # 住宅ローン控除額
    attr_accessor :mortgage_deductible # 住宅ローン控除可能額
    attr_accessor :social_insurance # 社会保険料等の金額
    attr_accessor :small_scale_mutual_aid # 小規模共済掛金の金額
    attr_accessor :social_insurance_premium # 給与から控除していない社会保険料
    attr_accessor :life_insurance_deduction # 生命保険料の控除額
    attr_accessor :exemption # 控除情報
    attr_accessor :employment_or_retirement_date # 入退社日（レポート出力対象のみ設定）
    attr_accessor :employment_year # 入社年？
    attr_accessor :retirement_year # 退社年？

    def social_insurance_internal
      small_scale_mutual_aid.to_i + social_insurance_premium.to_i
    end

    def social_insurance_total
      social_insurance + social_insurance_internal
    end

  end
end
