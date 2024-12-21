module Validators

  class UniqueAccountValidator < ActiveModel::Validator

    def validate(record)
      if record.my_account_id.to_i == record.account_id.to_i
        record.errors.add(:base, I18n.t('errors.messages.accounts_duplicated'))
      end
    end

  end
end
