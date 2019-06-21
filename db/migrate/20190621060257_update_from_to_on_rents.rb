class UpdateFromToOnRents < ActiveRecord::Migration[5.2]
  def up
    Rent.find_each do |r|
      r.start_from = Date.strptime(r.ymd_start.to_s, '%Y%m%d')
      r.end_to = Date.strptime(r.ymd_end.to_s, '%Y%m%d') if r.ymd_end.to_i > 0
      r.save
    end
  end
  
  def end
  end
end
