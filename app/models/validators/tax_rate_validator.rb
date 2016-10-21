module Validators

  class TaxRateValidator < ActiveModel::Validator

    def validate(record)
      return if record.tax_type_nontaxable?

      if record.tax_rate.to_f == 0
        record.errors[:tax_rate] << I18n.t('errors.messages.blank')
      end
    end

  end
end
