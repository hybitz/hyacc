require 'test_helper'

class Reports::ExecutiveSalariesLogicTest < ActiveSupport::TestCase

  def test_build_model_sets_employee_fields_from_employee
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    logic = Reports::ExecutiveSalariesLogic.new(finder)
    model = logic.build_model

    detail = model.details.find { |d| d.employee_name == executive.fullname }
    assert detail
    assert_equal executive.position, detail.position
    assert_equal executive.address_on(logic.end_ymd), detail.address
    assert_equal executive.full_time, detail.full_time
    assert_equal executive.duty_description, detail.duty_description
    assert_equal executive.relationship_to_representative, detail.relationship
    assert_equal executive.representative_or_family_type, detail.representative_or_family_type

    assert_equal 400_000, detail.retirement_allowance_amount
    assert_equal 400_000, model.total_executive_retirement_allowance_amount
  end

  def test_sorted_details_sorts_representative_group_first_then_salary_desc
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    logic = Reports::ExecutiveSalariesLogic.new(finder)
    model = logic.build_model
    model.details = [
      detail_model('other_high', 700_000, REPRESENTATIVE_OR_FAMILY_TYPE_FAMILY),
      detail_model('representative_low', 100_000, REPRESENTATIVE_OR_FAMILY_TYPE_REPRESENTATIVE),
      detail_model('other_mid', 500_000, nil),
      detail_model('representative_high', 900_000, REPRESENTATIVE_OR_FAMILY_TYPE_REPRESENTATIVE)
    ]

    assert_equal ['representative_high', 'representative_low', 'other_high', 'other_mid'], model.sorted_details.map(&:employee_name)
  end

  def test_total_salary_amount_for_representative_or_family
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    logic = Reports::ExecutiveSalariesLogic.new(finder)
    model = logic.build_model
    model.total_employee_salary_amount_for_representative_or_family = 300_000
    model.details = [
      detail_model('representative', 500_000, REPRESENTATIVE_OR_FAMILY_TYPE_REPRESENTATIVE),
      detail_model('family', 200_000, REPRESENTATIVE_OR_FAMILY_TYPE_FAMILY),
      detail_model('none', 900_000, nil)
    ]

    assert_equal 700_000, model.total_executive_salary_amount_for_representative_or_family
    assert_equal 1_000_000, model.total_salary_amount_for_representative_or_family
  end

  def test_build_model_sets_employee_salary_amount_for_representative_or_family_zero_when_target_employee_not_found
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    finder.branch_id = 1
    logic = Reports::ExecutiveSalariesLogic.new(finder)
    model = logic.build_model

    assert_equal 0, model.total_employee_salary_amount_for_representative_or_family
  end

  def test_build_model_applies_branch_filter_to_employee_salary_amount_for_representative_or_family
    branch3_finder = ReportFinder.new(user)
    branch3_finder.fiscal_year = 2016
    branch3_finder.company_id = company.id
    branch3_finder.branch_id = 3
    branch3_logic = Reports::ExecutiveSalariesLogic.new(branch3_finder)
    branch3_model = branch3_logic.build_model

    no_branch_finder = ReportFinder.new(user)
    no_branch_finder.fiscal_year = 2016
    no_branch_finder.company_id = company.id
    no_branch_finder.branch_id = 0
    no_branch_logic = Reports::ExecutiveSalariesLogic.new(no_branch_finder)
    no_branch_model = no_branch_logic.build_model

    branch3_amount = branch3_model.total_employee_salary_amount_for_representative_or_family
    no_branch_amount = no_branch_model.total_employee_salary_amount_for_representative_or_family

    assert_equal 110_000, branch3_amount
    assert_equal 110_000, no_branch_amount
  end

  def test_build_model_total_salary_amount_for_representative_or_family_is_sum_of_components
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    finder.branch_id = 3
    logic = Reports::ExecutiveSalariesLogic.new(finder)
    model = logic.build_model

    assert_equal 50_000, model.total_executive_salary_amount_for_representative_or_family
    assert_equal 110_000, model.total_employee_salary_amount_for_representative_or_family
    assert_equal 160_000, model.total_salary_amount_for_representative_or_family
  end

  private

  def detail_model(name, salary_amount, representative_or_family_type)
    detail = Reports::ExecutiveSalariesDetailModel.new
    detail.employee_name = name
    detail.representative_or_family_type = representative_or_family_type
    detail.fixed_regular_salary_amount = salary_amount
    detail.other_salary_amount = 0
    detail
  end
end
