require 'rake'

namespace :hyacc do
  namespace :journal do

    desc '明細のない伝票を検索します'
    task without_details: :environment do
      sql = SqlBuilder.new
      sql.append('not exists (')
      sql.append('  select 1 from journal_details jd where jd.journal_id = journals.id')
      sql.append(')')
      puts Journal.where(sql.to_a).to_yaml
    end
    
    desc '本体価格と消費税額をリストアップします'
    task tax_amount: :environment do
      fiscal_year = ENV['FISCAL_YEAR'] || Date.today.year
      
      c = Company.first
      fy = c.fiscal_years.find_by(fiscal_year: fiscal_year)
      ym_range = HyaccDateUtil.get_year_months(fy.start_year_month, 12)
      puts "#{fiscal_year} 年度（#{ym_range.first} ～ #{ym_range.last}）の伝票をリストアップします。"

      ym_range.each do |ym|
        Journal.where(company_id: c.id, ym: ym, deleted: false).find_each do |j|
          diff = false
          messages = []
          messages << "#{j.id}: #{j.date} #{j.remarks}"

          j.normal_details.each do |jd|
            expected = 0
            if jd.tax_type_inclusive?
              expected_tax_amount = jd.input_amount - (jd.input_amount / (1 + jd.tax_rate)).ceil
            elsif jd.tax_type_exclusive?
              expected_tax_amount = (jd.input_amount * jd.tax_rate).floor
            else
              next
            end
            
            messages << "\t#{jd.id}: #{jd.tax_type_name} #{jd.input_amount}（#{jd.tax_amount}） => #{expected_tax_amount}"
            diff = expected_tax_amount != jd.tax_amount
          end
          
          puts messages.join("\n") if diff
        end
      end
    end
  end
end