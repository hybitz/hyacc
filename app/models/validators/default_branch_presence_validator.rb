module Validators

  class DefaultBranchPresenceValidator < ActiveModel::Validator

    def validate(record)
      return unless record.user
      if record.branch_employees.select {|be| ! be.deleted? && be.default_branch? }.empty?
        record.errors.add(:base, I18n.t('errors.messages.default_branch_required'))
      end
    end
  end
end