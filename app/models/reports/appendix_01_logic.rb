module Reports
  class Appendix01Logic < BaseLogic

    def build_model
      ret = Appendix01Model.new

      appendix_04_logic = Appendix04Logic.new(finder)
      ret.appendix_04_model = appendix_04_logic.build_model
      ret
    end

  end

  class Appendix01Model
    attr_accessor :appendix_04_model

    # 所得金額又は欠損金額
    def income_amount
      appendix_04_model.income_amount
    end
  end
end
