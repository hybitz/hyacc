module Validators
  
  class UniqueSubAccountsValidator < ActiveModel::Validator
    include HyaccConst

    def validate(record)
      return if [SUB_ACCOUNT_TYPE_EMPLOYEE].include?(record.sub_account_type)

      codes = []
      record.sub_accounts_all.each do |sa|
        if codes.include?(sa.code)
          record.errors[:base] << I18n.t('errors.messages.sub_accounts_duplicated')
          return
        end

        codes << sa.code
      end
    end

  end
end
