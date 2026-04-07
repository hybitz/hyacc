require 'test_helper'
require 'minitest/mock'

class AdHocNotificationCleanerTest < ActiveSupport::TestCase
  def setup
    ym = 202508
    employee = Employee.find(9)

    @payroll = Payroll.find_by(ym: ym, employee_id: employee.id)
    past_ym = (1..3).map{|i| (Date.new(ym/100, ym%100, 1) << i).strftime('%Y%m').to_i}
    payrolls_by_ym = Payroll.where(ym: past_ym, employee_id: employee.id, is_bonus: false).index_by(&:ym)
    @past_payrolls = past_ym.map { |pym| payrolls_by_ym[pym] }
    @context = PayrollNotification::PayrollNotificationContext.new(
      payroll: @payroll,
      ym: ym,
      employee: employee,
      past_ym: past_ym,
      past_payrolls: @past_payrolls
    )
    @notification = Notification.find(3)
  end

  def test_notificationのdeletedフラグがfalseのままで更新が不要な場合
    assert_equal @payroll.monthly_standard, @past_payrolls[0].monthly_standard
 
    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
  end
  
  def test_notificationのdeletedフラグがfalseからtrueに更新が必要な場合
    @payroll.update!(monthly_standard: 330000)
    assert_not_equal @payroll.monthly_standard, @past_payrolls[0].monthly_standard

    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
    assert @notification.reload.deleted?
  end

  def test_notificationのdeletedフラグがtrueのままで更新が不要な場合
    @notification.update!(deleted: true)
    @payroll.update!(monthly_standard: 330000)
    assert_not_equal @payroll.monthly_standard, @past_payrolls[0].monthly_standard

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
    message = nil
    @payroll.update!(monthly_standard: 330000)
    assert_not_equal @payroll.monthly_standard, @past_payrolls[0].monthly_standard

    HyaccLogger.stub(:info, ->(msg) {message = msg}) do
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end
  
    assert_equal "随時改定の対応チェック 更新成功: notification_id=#{@notification.id}", message
  end

  def test_should_be_deleted_based_on_annual_determination?
    employee = Employee.find(8)
    @payroll = Payroll.find_by(ym: 202508, employee_id: employee.id)
    @notification = Notification.create!(ym: 202508, category: :ad_hoc_revision, employee_id: employee.id, deleted: false)
    @payroll.update!(monthly_standard: 320_000)
    base_standard = @payroll.monthly_standard


    Payroll.find_by(ym: 202509, employee_id: @payroll.employee_id).update!(monthly_standard: base_standard + 40_000)
    copy = @payroll.dup
    copy.monthly_standard = base_standard + 40_000
    copy.ym = 202510
    copy.save!

    ym = 202510

    [202506, 202507, 202508].each do |ym|
      pr = Payroll.find_or_initialize_regular_payroll(ym, employee.id)
      pr.update!(housing_allowance: 40_000)
    end

    payroll = Payroll.find_by(ym: ym, employee_id: employee.id)
    past_ym = (1..3).map{|i| (Date.new(ym/100, ym%100, 1) << i).strftime('%Y%m').to_i}
    past_payrolls = past_ym.map{|ym| Payroll.find_or_initialize_regular_payroll(ym, employee.id)}
    context = PayrollNotification::PayrollNotificationContext.new(
      payroll: payroll,
      ym: ym,
      employee: employee,
      past_ym: past_ym,
      past_payrolls: past_payrolls
    )
    
    assert_changes '@notification.reload.deleted' do
      PayrollNotification::AdHocRevisionCleaner.call(context)
    end

    assert @notification.reload.deleted?
  end

end