module Validators

  # 補助科目を持つ勘定科目の場合は補助科目の指定が必須
  class SubAccountPresenceValidator < ActiveModel::Validator

    def validate(record)
      return unless record.account

      if record.account.sub_accounts.present?
        if record.sub_account_id.to_i == 0
          record.errors.add(:sub_account, I18n.t('errors.messages.empty'))
        end
      end
    end

  end
end
