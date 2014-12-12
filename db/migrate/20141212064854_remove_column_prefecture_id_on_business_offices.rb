class RemoveColumnPrefectureIdOnBusinessOffices < ActiveRecord::Migration
  def up
    remove_column :business_offices, :prefecture_id
  end

  def down
    add_column :business_offices, :prefecture_id, :integer, :null => false
    
    BusinessOffice.find_each do |bo|
      bo.update_column(:prefecture_id, bo.prefecture_code.to_i) or raise '都道府県の更新エラー'
    end
  end
end
