require 'test_helper'

class NonResidentCodeValidatorTest < ActiveSupport::TestCase
  include HyaccConst

  def setup
    @dfm = DependentFamilyMember.first
    @dfm.exemption_type = EXEMPTION_TYPE_FAMILY
    @dfm.live_in = false
  end

  def test_should_reject_non_resident_code_when_live_in_is_true
    @dfm.live_in = true
    @dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_OTHER
    @dfm.non_resident_code = NON_RESIDENT_CODE_30_70_STUDENT
    assert @dfm.invalid?
    assert @dfm.errors[:non_resident_code].include?(I18n.t('errors.messages.not_allowed_when_live_in'))
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

  def test_validate_code_nil_and_live_in_true
    @dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_OVER_70_WITH
    @dfm.non_resident_code = NON_RESIDENT_CODE_UNDER_30_OR_OVER_70 
    assert @dfm.invalid?
    assert @dfm.errors[:non_resident_code].include?(I18n.t('errors.messages.dependents_over_70_not_allowed'))
    assert @dfm.errors[:live_in].include?(I18n.t('errors.messages.required_to_be'))

    @dfm.non_resident_code = nil
    @dfm.live_in = true
    assert @dfm.valid?
  end

end