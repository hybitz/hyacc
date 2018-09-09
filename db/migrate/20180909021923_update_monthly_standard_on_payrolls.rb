class UpdateMonthlyStandardOnPayrolls < ActiveRecord::Migration[5.2]
  def up
    Payroll.find_each do |p|
      next if p.welfare_pension == 0

      date = Date.new(p.year, p.month, -1)
      bo = p.employee.default_branch.business_office_at(date)
      
      list = TaxJp::SocialInsurance.find_all_by_date_and_prefecture(date, bo.prefecture_code)
      social_insurance = list.find do |si|
        [si.welfare_pension.general_amount_half.to_i, si.welfare_pension.general_amount_half.to_i + 1].include?(p.welfare_pension)
      end
      
      puts "#{p.ym} #{p.employee.name} #{bo.prefecture_name}: 厚生年金 => #{p.welfare_pension}, 標準月額報酬 => #{social_insurance.grade.monthly_standard}"

      p.update_column(:monthly_standard, social_insurance.grade.monthly_standard)
    end
  end

  def down
  end
end
