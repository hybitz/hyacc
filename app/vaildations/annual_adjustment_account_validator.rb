class AnnualAdjustmentAccountValidator < ActiveModel::EachValidator
  include HyaccConst

  def validate_each(record, attribute, value)
    return unless value.present?

    a = Account.where(id: value, journalizable: true, deleted: false).first
    unless a
      record.errors.add attribute, (options[:message] || I18n.t('errors.messages.non_existing_account'))
      return
    end

    sa = a.get_sub_account_by_code(TAX_DEDUCTION_TYPE_INCOME_TAX)
    unless sa and not sa.deleted?
      record.errors.add attribute, (options[:message] || I18n.t('errors.messages.income_tax_sub_account_required'))
      return
    end
  end

end
