class AddColumnEmploymentDateToUsers < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :users, "employment_date", :date, :null=>false
    add_column :users, "sex", :string, :limit=>1, :null=>false
    # カラム情報を最新にする
    User.reset_column_information
    
    # 入社日を設定する
    User.update_all("employment_date='2007/2/28'")
    # 性別を設定する
    User.update_all("sex='M'")
  end

  def self.down
    remove_column :users, "employment_date"
    remove_column :users, "sex"
  end
end
