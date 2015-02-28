class WelcomeController < Base::HyaccController
  include FirstBoot
  before_action :authenticate_user!

  view_attribute :title => 'トップ'
  
  def index
    # 消費税をチェックしたほうがよさそうな伝票
    @tax_check_count = TaxFinder.new(current_user).count

    # 未清算の仮負債
    @debts, @debt_sum = DebtFinder.new(current_user).list
    
    # みなし消費税の計算額と仕訳金額がずれているかチェック
    # 本締め後なのにずれている場合のみ警告
    fy = current_user.company.current_fiscal_year
    if fy.tax_management_type == TAX_MANAGEMENT_TYPE_DEEMED and not fy.is_open
      logic = DeemedTax::DeemedTaxLogic.new(fy)
      @dtm = logic.get_deemed_tax_model
    end
  end
  
end
