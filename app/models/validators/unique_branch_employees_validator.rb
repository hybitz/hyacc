module Validators
  
  class UniqueBranchEmployeesValidator < ActiveModel::Validator

    def validate(record)
      return unless record.branch_employees

      branch_employees = record.branch_employees.select {|be| ! be.deleted? }
      return unless branch_employees

      branch_ids = []      
      branch_employees.each do |be|
        if branch_ids.include?(be.branch_id)
          record.errors.add(:base, I18n.t('errors.messages.branch_employees_duplicated'))
          return
        end

        branch_ids << be.branch_id
      end
    end

  end
end