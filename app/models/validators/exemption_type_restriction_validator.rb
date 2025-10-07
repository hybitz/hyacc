module Validators
  class ExemptionTypeRestrictionValidator < ActiveModel::Validator
    include HyaccConst

    def validate(record)
      return if record.exemption_type == EXEMPTION_TYPE_FAMILY

      if record.family_sub_type.present?
        record.errors.add(:family_sub_type, I18n.t('errors.messages.exemption_type_family_required'))
      end

      if record.non_resident_code.present?
        record.errors.add(:non_resident_code, I18n.t('errors.messages.exemption_type_family_required'))
      end
    end
  end
end
