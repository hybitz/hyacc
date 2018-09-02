require 'rake'

namespace :hyacc do
  namespace :payroll do

    desc '月額標準報酬の算出'
    task find_standard_renumeration: :environment do
      Payroll.find_each do |p|
        date = Date.new(p.year, p.month, -1)
        bo = p.employee.default_branch.business_office_at(date)
        
        list = TaxJp::SocialInsurance.find_all_by_date_and_prefecture(date, bo.prefecture_code)
        social_insurance = list.find{|si| si.welfare_pension.general_amount_half.to_i == p.welfare_pension }
        puts "#{p.ym} #{p.employee.name} #{bo.prefecture_name}: #{p.welfare_pension} => #{social_insurance}"
      end
    end
  end
end