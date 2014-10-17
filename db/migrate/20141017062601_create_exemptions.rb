class CreateExemptions < ActiveRecord::Migration
  def change
    create_table :exemptions do |t|
      t.string :employee_id, :null => false
      t.integer :yyyy, :null => false
      t.integer :small_scale_mutual_aid, :null => false, :default => 0         # 小規模共済掛金
      t.integer :life_insurance_premium, :null => false, :default => 0         # 生命保険料
      t.integer :earthquake_insurance_premium, :null => false, :default => 0   # 地震保険料
      t.integer :special_tax_for_spouse, :null => false, :default => 0         # 配偶者特別控除
      t.integer :basic_etc, :null => false, :default => 0                      # 配偶者、扶養、基礎、障害者控除の合計
      t.timestamps
    end
  end
end
