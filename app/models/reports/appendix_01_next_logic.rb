module Reports
  class Appendix01NextLogic < BaseLogic

    def build_model
      ret = Appendix01NextModel.new

      appendix_04_logic = Appendix04Logic.new(finder)
      ret.appendix_04_model = appendix_04_logic.build_model
      ret
    end

  end

  class Appendix01NextModel
    attr_accessor :appendix_04_model

    # 所得金額又は欠損金額
    def income_amount
      (appendix_04_model.income_amount / 1000).floor * 1000
    end

    # 丸め前法人税額
    def pre_corporate_tax_amount
      income_amount * 0.15
    end

    # 法人税額
    def corporate_tax_amount
      (pre_corporate_tax_amount / 1000).floor * 1000
    end

    # 地方法人税額額
    def local_corporate_tax_amount
      corporate_tax_amount * 0.103
    end

  end
end
