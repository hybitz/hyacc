module Validators

  class NonResidentCodeValidator < ActiveModel::Validator
    include HyaccConst

    def validate(record)
      if !record.non_resident? && record.non_resident_code.present?
        record.errors.add(:non_resident_code, I18n.t('errors.messages.not_allowed_for_residents'))
      end

      return unless record.exemption_type == EXEMPTION_TYPE_FAMILY && record.non_resident?

      case record.family_sub_type
      when FAMILY_SUB_TYPE_DEPENDENTS_19_23, FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITHOUT, FAMILY_SUB_TYPE_SPECIFIED
        validate_code_fixed_under_30_or_over_70(record)
      when FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITH
        validate_code_nil_and_non_resident_false(record)
      end
    end

    private

    def validate_code_fixed_under_30_or_over_70(record)
      if record.non_resident_code != NON_RESIDENT_CODE_UNDER_30_OR_OVER_70
        record.errors.add(:non_resident_code, I18n.t("errors.messages.under_30_or_over_70_only"))
      end
    end

    def validate_code_nil_and_non_resident_false(record)
      if record.non_resident_code.present?
        record.errors.add(:non_resident_code, I18n.t('errors.messages.dependents_over_70_not_allowed'))
      end
      if record.non_resident?
        record.errors.add(:non_resident, I18n.t('errors.messages.cannot_select_dependents_over_70_with'))
      end
    end
  end
end