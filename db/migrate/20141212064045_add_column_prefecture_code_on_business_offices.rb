class AddColumnPrefectureCodeOnBusinessOffices < ActiveRecord::Migration
  def up
    add_column :business_offices, :prefecture_code, :string, :limit => 2, :null => false

    BusinessOffice.find_each do |bo|
      code = "%02d" % bo.prefecture_id
      bo.update_column(:prefecture_code, code) or raise '都道府県の更新エラー'
    end
  end
  
  def down
    remove_column :business_offices, :prefecture_code
  end
end
