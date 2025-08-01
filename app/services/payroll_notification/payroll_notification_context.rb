module PayrollNotification
  PayrollNotificationContext = Struct.new(
    :payroll, :ym, :employee, :past_ym, :past_payrolls,
    keyword_init: true
  )
end