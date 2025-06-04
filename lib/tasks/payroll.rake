require 'rake'

namespace :hyacc do
  namespace :payroll do

    desc '月額標準報酬の算出'
    task find_standard_renumeration: :environment do
      Payroll.find_each do |p|
        next if p.welfare_pension == 0

        bo = p.employee.default_branch.business_office_at(date)
        
        list = TaxJp::SocialInsurance.find_all_by_date_and_prefecture(date, bo.prefecture_code)
        social_insurance = list.find do |si|
          [si.welfare_pension.general_amount_half.to_i, si.welfare_pension.general_amount_half.to_i + 1].include?(p.welfare_pension)
        end
        puts "#{p.ym} #{p.employee.name} #{bo.prefecture_name}: #{p.welfare_pension} => #{social_insurance.grade.monthly_standard}"
      end
    end
  end
end