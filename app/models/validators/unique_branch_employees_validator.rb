module Validators
  
  class UniqueBranchEmployeesValidator < ActiveModel::Validator

    def validate(record)
      branch_employees = record.branch_employees.select {|be| ! be.deleted? }
      return if branch_employees.empty?
      validate_branch(record, branch_employees)
      validate_default_branch(record, branch_employees)
    end

    private

    def validate_branch(record, branch_employees)
      branch_ids = []
      branch_employees.each do |be|
        if branch_ids.include?(be.branch_id)
          record.errors.add(:base, I18n.t('errors.messages.branch_employees_duplicated'))
          return
        end

        branch_ids << be.branch_id
      end
    end

    def validate_default_branch(record, branch_employees)
      if branch_employees.select {|be| be.default_branch? }.size > 1
        record.errors.add(:base, I18n.t('errors.messages.default_branches_duplicated'))
      end
    end

  end
end