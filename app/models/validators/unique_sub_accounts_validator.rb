module Validators
  
  class UniqueSubAccountsValidator < ActiveModel::Validator

    def validate(record)
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
