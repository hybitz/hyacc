module Bs::InvestmentsHelper
  # 関連付け時（新規で既存伝票に紐づける場合）のみフォームをロックするか。
  def investment_form_locked?(investment)
    investment.new_record? && investment.linked_to_transfer_slip?
  end

  def investment_form_readonly_opts(investment)
    investment_form_locked?(investment) ? { readonly: true, class: 'readonly-as-disabled' } : {}
  end
end
