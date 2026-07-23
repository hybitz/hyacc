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
      'Branch' => {
        error: HyaccErrors::ERR_BRANCH_LINKED,
        checks: [
          ->(record) { Branch.where(parent_id: record.id, deleted: false).exists? },
          ->(record) {
            branch_ids = record.self_and_descendants.map(&:id)
            JournalDetail.where(branch_id: branch_ids).exists? ||
              BranchEmployee
                .joins(:employee)
                .where(employees: { deleted: false })
                .where(branch_id: branch_ids, deleted: false)
                .exists? ||
              SimpleSlipTemplate.where(branch_id: branch_ids, deleted: false).exists?
          },
        ],
      },
      'Customer' => {
        error: HyaccErrors::ERR_CUSTOMER_LINKED,
        checks: [
          ->(record) { Career.where(customer_id: record.id).exists? },
          ->(record) { Investment.where(customer_id: record.id).exists? },
          ->(record) { Rent.where(customer_id: record.id).exists? },
        ],
      },
      'DonationRecipient' => {
        error: HyaccErrors::ERR_DONATION_RECIPIENT_LINKED,
        checks: [
          ->(record) { JournalDetail.where(donation_recipient_id: record.id).exists? },
        ],
      },
      'Employee' => {
        error: HyaccErrors::ERR_EMPLOYEE_LINKED,
        checks: [
          ->(record) { Career.where(employee_id: record.id).exists? },
          ->(record) { Exemption.where(employee_id: record.id).exists? },
          ->(record) { InhabitantTax.where(employee_id: record.id).exists? },
        ],
      },
    }

    def validate(record)
      rule = DELETION_RULES.fetch(record.class.name) do
        raise ArgumentError,
              "ReferencedOnDeletionValidator: DELETION_RULES に #{record.class.name} のルールが定義されていません"
      end

      return unless record.will_save_change_to_deleted? && record.deleted?

      if rule[:checks].any? { |check| check.call(record) }
        record.errors.add(:base, rule[:error])
      end
    end

  end
end
