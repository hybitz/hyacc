namespace :hyacc do
  namespace :payroll_notification do

    desc "Payrollからお知らせを登録・削除"
    task handle_and_cleanup_based_on_payroll: :environment do
      cron_logger = ActiveSupport::Logger.new(Rails.root.join("log/cron.log"))
      cron_logger.formatter = proc do |severity, time, progname, msg|
        parts = []
        parts << "[#{time.strftime('%Y-%m-%d %H:%M')}]"
        parts << "[#{severity}]"
        parts << "[#{progname}]" if progname
        parts << msg
        parts.join(" ") + "\n"
      end      
    
      cron_logger.info("Payrollからお知らせの登録・削除を開始する") 
      PayrollNotification::PayrollNotificationProcessor.call(logger: cron_logger)
      cron_logger.progname = nil
      cron_logger.info("Payrollからお知らせの登録・削除を終了する")
    end

  end
end