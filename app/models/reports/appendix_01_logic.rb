module Reports
  class Appendix01Logic < BaseLogic

    def build_model
      ret = Appendix01Model.new

      appendix_01_next_logic = Appendix01NextLogic.new(finder)
      ret.appendix_01_next_model = appendix_01_next_logic.build_model

      appendix_04_logic = Appendix04Logic.new(finder)
      ret.appendix_04_model = appendix_04_logic.build_model

      # TODO 定数化
      ret.interim_corporate_tax_amount = get_this_term_interim_amount(ACCOUNT_CODE_TEMP_PAY_CORPORATE_TAXES, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      ret.interim_local_corporate_tax_amount = get_this_term_interim_amount(ACCOUNT_CODE_TEMP_PAY_CORPORATE_TAXES, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)

      ret
    end

  end

  class Appendix01Model
    attr_accessor :appendix_01_next_model
    attr_accessor :appendix_04_model
    attr_accessor :interim_corporate_tax_amount # 中間申告分の法人税額
    attr_accessor :interim_local_corporate_tax_amount # 中間申告分の地方法人税額

    # 所得金額又は欠損金額
    def income_amount
      appendix_04_model.income_amount
    end

    # 丸め前法人税額
    def pre_corporate_tax_amount
      appendix_01_next_model.pre_corporate_tax_amount
    end

    # 差引所得に対する法人税額
    def corporate_tax_amount
      (pre_corporate_tax_amount / 100).floor * 100
    end

    # 差引確定法人税額
    def final_corporate_tax_amount
      corporate_tax_amount - interim_corporate_tax_amount
    end

    # 課税標準法人税額
    def standard_corporate_tax_amount
      appendix_01_next_model.corporate_tax_amount
    end

    # 丸め前地方法人税額
    def pre_local_corporate_tax_amount
      appendix_01_next_model.local_corporate_tax_amount
    end
  
    # 地方法人税額
    def local_corporate_tax_amount
      (pre_local_corporate_tax_amount / 100).floor * 100
    end

    # 差引確定地方法人税額
    def final_local_corporate_tax_amount
      local_corporate_tax_amount - interim_local_corporate_tax_amount
    end

  end
end
