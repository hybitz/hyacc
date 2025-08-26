namespace :hyacc do
  namespace :payroll_notification do

    desc "Payrollからお知らせを登録・削除"
    task handle_and_cleanup_based_on_payroll: :environment do   
      HyaccLogger.info("Payrollからお知らせの登録・削除を開始する") 
      PayrollNotification::PayrollNotificationProcessor.call
      HyaccLogger.info("Payrollからお知らせの登録・削除を終了する")
    end

  end
end