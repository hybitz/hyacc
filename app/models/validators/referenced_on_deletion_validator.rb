module Validators

  class ReferencedOnDeletionValidator < ActiveModel::Validator

    DELETION_RULES = {
      'Bank' => {
        error: HyaccErrors::ERR_BANK_LINKED,
        checks: [
          ->(record) { BankAccount.where(bank_id: record.id, deleted: false).exists? },
          ->(record) { EmployeeBankAccount.where(bank_id: record.id).exists? },
        ],
      },
      'BankAccount' => {
        error: HyaccErrors::ERR_BANK_ACCOUNT_LINKED,
        checks: [
          ->(record) { Investment.where(bank_account_id: record.id).exists? },
        ],
      },
      'DonationRecipient' => {
        error: HyaccErrors::ERR_DONATION_RECIPIENT_LINKED,
        checks: [
          ->(record) { JournalDetail.where(donation_recipient_id: record.id).exists? },
        ],
      },
    }

    def validate(record)
      return unless record.will_save_change_to_deleted? && record.deleted?

      rule = DELETION_RULES[record.class.name]
      return unless rule

      if rule[:checks].any? { |check| check.call(record) }
        record.errors.add(:base, rule[:error])
      end
    end

  end
end
