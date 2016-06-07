require 'rake'

namespace :hyacc do
  namespace :ledger do

    desc '貸借がずれた時期がないかチェックします'
    task :balance_check => :environment do
      Company.find_each do |c|
        puts c.name
        ym = Journal.where(:company_id => c.id).minimum(:ym)
        max_ym = Journal.where(:company_id => c.id).maximum(:ym)

        while ym < max_ym do
          first_day = Date.new(ym / 100, ym % 100, 1)
          first_day.end_of_month.day.times do |day|
            date = Date.new(ym / 100, ym % 100, day + 1)
            puts date.strftime('%Y-%m-%d')

            c.branches.each do |b|
              jh_condition = {:company_id => c.id, :ym => ym, :day => date.day}
              debit = JournalDetail.joins(:journal_header).where(:journal_headers => jh_condition,
                  :dc_type => JournalDetail::DC_TYPE_DEBIT, :branch_id => b.id).sum(:amount)
              credit = JournalDetail.joins(:journal_header).where(:journal_headers => jh_condition,
                  :dc_type => JournalDetail::DC_TYPE_CREDIT, :branch_id => b.id).sum(:amount)
              if debit != credit
                fail "#{b.name} : 借方 #{debit} : 貸方 #{credit}"
              end
            end
          end
          
          ym = first_day.next_month.strftime('%Y%m').to_i
        end
      end
    end
  end
end