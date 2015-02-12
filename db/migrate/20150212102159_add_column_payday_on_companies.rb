class AddColumnPaydayOnCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :payday, :string, :null => false, :default => "0,25" # (-1:前月、0:当月、1：翌月) , 日
    c = Company.find(1)
    c.payday = "1,7"
    c.save!
  end
end
