class UpdateWeekDayOfWorkOnPayrolls < ActiveRecord::Migration
  def up
    Payroll.find_each do |p|
      weekday = HyaccDateUtil.weekday_of_month(p.ym.to_i/100, p.ym.to_i%100)
      p.days_of_work = weekday
      p.hours_of_work = weekday * 8
      puts "#{p.id}:#{p.ym} => #{p.days_of_work}"
      p.save!
    end
  end
  def down
  end
end
