module Validators

  # 補助科目を持つ勘定科目の場合は補助科目の指定が必須
  class MySubAccountPresenceValidator < ActiveModel::Validator

    def validate(record)
      return unless record.my_account

      if record.my_account.sub_accounts.present?
        if record.my_sub_account_id.to_i == 0
          record.errors[:my_sub_account] = I18n.t('errors.messages.empty')
        end
      end
    end

  end
end
