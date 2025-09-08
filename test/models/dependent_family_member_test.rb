require 'test_helper'

class DependentFamilyMemberTest < ActiveSupport::TestCase
  include HyaccConst

  def test_should_require_family_sub_type_if_exemption_type_is_family
    dfm = DependentFamilyMember.first
    assert_nil dfm.family_sub_type
    assert dfm.live_in?
    dfm.exemption_type = EXEMPTION_TYPE_FAMILY
    assert dfm.invalid?

    dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_19_23
    assert dfm.valid?
  end

  def test_should_require_non_resident_code_if_exemption_type_is_family_and_live_in_is_false
    dfm = DependentFamilyMember.first
    dfm.exemption_type = EXEMPTION_TYPE_FAMILY
    dfm.live_in = false
    dfm.family_sub_type = FAMILY_SUB_TYPE_DEPENDENTS_19_23
    assert dfm.invalid?

    dfm.non_resident_code = NON_RESIDENT_CODE_UNDER_30_OR_OVER_70
    assert dfm.valid?
  end

  def test_should_convert_empty_string_to_nil
    dfm = DependentFamilyMember.first
    dfm.family_sub_type = ''
    dfm.non_resident_code = ''
    assert dfm.save!
    assert_nil dfm.reload.family_sub_type
    assert_nil dfm.reload.non_resident_code
  end

end
