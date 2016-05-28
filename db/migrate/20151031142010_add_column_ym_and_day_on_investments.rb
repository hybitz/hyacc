class AddColumnYmAndDayOnInvestments < ActiveRecord::Migration

  def up
    add_column :investments, :ym, :integer, :null => false
    add_column :investments, :day, :integer, :null => false
    Investment.find_each do |inv|
      inv.ym = inv.yyyymmdd.to_s(:yyyymm).to_i
      inv.day = inv.yyyymmdd.to_s(:dd).to_i
      inv.save!
    end
    remove_column :investments, :yyyymmdd
  end

  def down
    add_column :investments, :yyyymmdd, :date, :null => false
    Investment.find_each do |inv|
      inv.yyyymmdd = to_date((inv.ym.to_s + inv.day.to_s).to_i)
      inv.save!
    end
    remove_column :investments, :ym
    remove_column :investments, :day
  end
end
