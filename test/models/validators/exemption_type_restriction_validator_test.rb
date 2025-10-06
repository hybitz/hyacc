require 'test_helper'

class ExemptionTypeRestrictionValidatorTest < ActiveSupport::TestCase
  include HyaccConst

  def setup
    @dfm = DependentFamilyMember.first
    @dfm.non_resident = true
  end

  def test_should_reject_family_sub_type_and_non_resident_code_if_exemption_type_is_not_family
    [EXEMPTION_TYPE_SPOUSE, EXEMPTION_TYPE_UNDER_16].each do |et|
      @dfm.exemption_type = et
      @dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_19_23
      @dfm.non_resident_code = NON_RESIDENT_CODE_UNDER_30_OR_OVER_70
      assert @dfm.invalid?
      assert @dfm.errors[:family_sub_type].include?(I18n.t('errors.messages.exemption_type_family_required'))
      assert @dfm.errors[:non_resident_code].include?(I18n.t('errors.messages.exemption_type_family_required'))
    end
  end

  def test_should_allow_family_sub_type_and_non_resident_code_if_exemption_type_is_family
    @dfm.exemption_type = EXEMPTION_TYPE_FAMILY
    @dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_19_23
    @dfm.non_resident_code = NON_RESIDENT_CODE_UNDER_30_OR_OVER_70
    assert @dfm.valid?
  end
end