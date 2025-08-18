require 'test_helper'
require 'minitest/mock'

class AdHocNotificationCleanerTest < ActiveSupport::TestCase
  def setup
    ym = 202508
    employee = Employee.find(8)
    BankAccount.second.update!(company_id: employee.company.id, for_payroll: true)
    employee.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025).save!

    @payroll = Payroll.find_by(ym: ym, employee_id: employee)
    past_ym = (1..3).map{|i| (Date.new(ym/100, ym%100, 1) << i).strftime('%Y%m').to_i}
    @past_payrolls = past_ym.map{|ym| Payroll.find_or_initialize_regular_payroll(ym, employee.id)}
    @context = PayrollNotification::PayrollNotificationContext.new(
      payroll: payroll,
      ym: ym,
      employee: employee,
      past_ym: past_ym,
      past_payrolls: @past_payrolls
    )
    @notification = Notification.create!(ym: past_ym[1], category: :ad_hoc_revision, employee_id: employee.id, deleted: false)
  end

  def test_notificationのdeletedフラグがfalseのままで更新が不要な場合
    assert_equal @payroll.monthly_standard, @past_payrolls[0].monthly_standard
 
    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
  end
  
  def test_notificationのdeletedフラグがfalseからtrueに更新が必要な場合
    @payroll.update!(monthly_standard: 330000)
    assert_not_equal @payroll.reload.monthly_standard, @past_payrolls[0].monthly_standard
    @context.payroll = @payroll

    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
    assert @notification.reload.deleted?
  end

  def test_notificationのdeletedフラグがtrueのままで更新が不要な場合
    @notification.update!(deleted: true)
    @payroll.update!(monthly_standard: 330000)
    assert_not_equal @payroll.reload.monthly_standard, @past_payrolls[0].monthly_standard
    @context.payroll = @payroll

    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
    assert @notification.reload.deleted?
  end

  def test_notificationのdeletedフラグがtrueからfalseに更新が必要な場合
    @notification.update!(deleted: true)
    assert_equal @payroll.monthly_standard, @past_payrolls[0].monthly_standard
 
    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
    assert_not @notification.reload.deleted?
  end

  def test_notificationがない場合でもエラーは起きない
    Notification.where(category: :ad_hoc_revision).delete_all
    assert_nothing_raised do
       PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
  end

  def test_更新に成功した場合はログを出力する
    @payroll.update!(monthly_standard: 330000)
    assert_not_equal @payroll.reload.monthly_standard, @past_payrolls[0].monthly_standard
    @context.payroll = @payroll

    expected_message = "更新成功：notification_id=#{@notification.id}"
    mock = Minitest::Mock.new
    Rails.stub(:logger, mock) do
      mock.expect(:info, nil) { |msg| msg.match?(expected_message) }
  
      PayrollNotification::AdHocRevisionCleaner.call(@context)
  
      mock.verify
    end 
  end

end