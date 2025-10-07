require 'test_helper'

class NonResidentCodeValidatorTest < ActiveSupport::TestCase
  include HyaccConst

  def setup
    @dfm = DependentFamilyMember.first
    @dfm.exemption_type = EXEMPTION_TYPE_FAMILY
    @dfm.non_resident = true
  end

  def test_should_reject_non_resident_code_when_non_resident_is_true
    @dfm.non_resident = false
    @dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_OTHER
    @dfm.non_resident_code = NON_RESIDENT_CODE_30_70_STUDENT
    assert @dfm.invalid?
    assert @dfm.errors[:non_resident_code].include?(I18n.t('errors.messages.not_allowed_for_residents'))
  end

  def test_validate_code_fixed_under_30_or_over_70
    [FAMILY_SUB_TYPE_DEPENDENTS_19_23, FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITHOUT, FAMILY_SUB_TYPE_SPECIFIED].each do |fst|
      @dfm.family_sub_type = fst
      @dfm.non_resident_code = NON_RESIDENT_CODE_30_70_STUDENT
      assert @dfm.invalid?
      assert @dfm.errors[:non_resident_code].include?(I18n.t('errors.messages.under_30_or_over_70_only'))

       @dfm.non_resident_code = NON_RESIDENT_CODE_UNDER_30_OR_OVER_70
       assert @dfm.valid?
    end
  end

  def test_validate_code_nil_and_non_resident_false
    @dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITH
    @dfm.non_resident_code = NON_RESIDENT_CODE_UNDER_30_OR_OVER_70 
    assert @dfm.invalid?
    assert @dfm.errors[:non_resident_code].include?(I18n.t('errors.messages.dependents_over_70_not_allowed'))
    assert @dfm.errors[:non_resident].include?(I18n.t('errors.messages.cannot_select_dependents_over_70_with'))

    @dfm.non_resident_code = nil
    @dfm.non_resident = false
    assert @dfm.valid?
  end

end