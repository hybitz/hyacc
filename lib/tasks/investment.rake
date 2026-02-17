require 'rake'

namespace :hyacc do
  namespace :investment do

    desc '有価証券以外の伝票区分で、有価証券に紐づいている伝票をチェックし、紐付いていたら解除する'
    task unlink_non_investment_journals: :environment do
      scope = Journal.where.not(slip_type: HyaccConst::SLIP_TYPE_INVESTMENT).where.not(investment_id: nil)
      count = scope.count

      if count.zero?
        puts '有価証券以外の伝票区分で、有価証券に紐づいている伝票はありません。'
        next
      end

      puts "有価証券以外の伝票区分で、有価証券に紐づいている伝票が#{count}件あります。紐付けを解除します。"
      journal_ids = scope.pluck(:id)
      updated = scope.update_all(investment_id: nil)
      puts "#{updated}件の紐付けを解除しました。（解除した伝票ID: #{journal_ids.join(', ')}）"
    end

  end
end
