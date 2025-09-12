namespace :hyacc do
  namespace :retirement_savings_notification do

    desc "退職金積立開始のお知らせを生成"
    task generate_start_notice: :environment do
      HyaccLogger.info("退職金積立開始のお知らせ生成を開始する") 
      RetirementSavingsNotification::StartNoticeGenerator.call
      HyaccLogger.info("退職金積立開始のお知らせ生成を終了する")
    end

    desc "退職金積立開始のお知らせを削除"
    task cleanup_start_notice: :environment do
      HyaccLogger.info("退職金積立開始のお知らせ削除を開始する")
      RetirementSavingsNotification::StartNoticeCleaner.call
      HyaccLogger.info("退職金積立開始のお知らせ削除を終了する")
    end
  end
end