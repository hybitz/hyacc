require 'test_helper'

class BranchTest < ActiveSupport::TestCase

  def test_parent
    ichy = Branch.find(2)
    head = Branch.find(1)
    parent = ichy.parent
    assert_equal head.id, parent.id
  end

  def test_business_office
    ichy = Branch.find(2)
    head = Branch.find(1)
    
    assert_equal head.business_office, ichy.business_office
  end

  def test_validates_code_presence
    branch = company.branches.build(branch_params.merge(code: ''))
    assert_not branch.valid?
    assert branch.errors[:code].present?
  end

  def test_validates_code_uniqueness
    existing = company.branches.where(deleted: false).first
    branch = company.branches.build(branch_params.merge(code: existing.code, parent_id: existing.parent_id))
    assert_not branch.valid?
    assert branch.errors[:code].include?(I18n.t('errors.messages.taken'))
  end

  def test_soft_deleted_branch_code_can_not_be_reused
    existing = company.branches.create!(branch_params.merge(code: '9001'))
    existing.update_column(:deleted, true)
    branch = company.branches.build(branch_params.merge(code: '9001'))
    assert branch.invalid?
  end

  def test_validates_formal_name_presence
    branch = company.branches.build(branch_params.merge(formal_name: ''))
    assert_not branch.valid?
    assert branch.errors[:formal_name].present?
  end
end
