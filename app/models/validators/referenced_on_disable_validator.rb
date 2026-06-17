module Validators

  class ReferencedOnDisableValidator < ActiveModel::Validator

    DISABLE_RULES = {
      'Bank' => {
        error: HyaccErrors::ERR_BANK_DISABLE_LINKED,
        checks: [
          ->(record) { BankAccount.where(bank_id: record.id, deleted: false).exists? },
          ->(record) { EmployeeBankAccount.where(bank_id: record.id).exists? },
        ],
      },
      'BankOffice' => {
        error: HyaccErrors::ERR_BANK_OFFICE_DISABLE_LINKED,
        checks: [
          ->(record) { BankAccount.where(bank_office_id: record.id, deleted: false).exists? },
          ->(record) { EmployeeBankAccount.where(bank_office_id: record.id).exists? },
        ],
      },
    }

    def validate(record)
      rule = DISABLE_RULES.fetch(record.class.name) do
        raise ArgumentError,
              "ReferencedOnDisableValidator: DISABLE_RULES に #{record.class.name} のルールが定義されていません"
      end

      return unless record.will_save_change_to_disabled? && record.disabled?

      if rule[:checks].any? { |check| check.call(record) }
        record.errors.add(:base, rule[:error])
      end
    end

  end
end
