namespace :hyacc do
  namespace :payroll_notification do

    desc "Payrollからお知らせを登録・削除"
    task handle_and_cleanup_based_on_payroll: :environment do
      HyaccLogger.info("Payrollからお知らせの登録・削除を開始する") 
      PayrollNotification::PayrollNotificationProcessor.call
      HyaccLogger.info("Payrollからお知らせの登録・削除を終了する")
    end

    desc "算定基礎届提出期限のお知らせを生成"
    task generate_report_submission_notice: :environment do
      HyaccLogger.info("算定基礎届提出期限のお知らせ生成を開始する")
      PayrollNotification::ReportSubmissionNoticeGenerator.call
      HyaccLogger.info("算定基礎届提出期限のお知らせ生成を終了する")
    end

    desc "算定基礎届提出期限のお知らせを削除"
    task cleanup_report_submission_notice: :environment do
      HyaccLogger.info("算定基礎届提出期限のお知らせ削除を開始する")
      PayrollNotification::ReportSubmissionNoticeCleaner.call
      HyaccLogger.info("算定基礎届提出期限のお知らせ削除を終了する")
    end

  end
end