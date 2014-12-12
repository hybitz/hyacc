class AddColumnBasicOnExemptions < ActiveRecord::Migration
  def up
    add_column :exemptions, :spouse, :integer, :null => false, :default => 0
    add_column :exemptions, :dependents, :integer, :null => false, :default => 0
    add_column :exemptions, :disabled_persons, :integer, :null => false, :default => 0
    add_column :exemptions, :basic, :integer, :null => false, :default => 0
    remove_column :exemptions, :basic_etc
    Exemptions.delete_all
    
        # ICHY
    Exemptions.new(:employee_id => 1, :yyyy=>2007, :basic => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2008, :basic => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2009, :small_scale_mutual_aid => 270000, :basic => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2010, :small_scale_mutual_aid => 360000, :basic => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2011, :small_scale_mutual_aid => 360000, :basic => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2012, :small_scale_mutual_aid => 360000, :basic => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2013, :small_scale_mutual_aid => 360000, :basic => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2014, :small_scale_mutual_aid => 360000, :basic => 380000).save!
    # HIRO
    Exemptions.new(:employee_id => 2, :yyyy=>2007, :basic => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2008, :basic => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2009, :small_scale_mutual_aid => 270000, :life_insurance_premium => 43824, :basic => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2010, :small_scale_mutual_aid => 360000, :life_insurance_premium => 41434, :basic => 380000, :spouse => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2011, :small_scale_mutual_aid => 360000, :life_insurance_premium => 50000, :basic => 380000, :spouse => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2012, :small_scale_mutual_aid => 360000, :life_insurance_premium => 50000, :basic => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2013, :small_scale_mutual_aid => 360000, :life_insurance_premium => 50000, :basic => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2014, :small_scale_mutual_aid => 360000, :life_insurance_premium => 50000, :basic => 380000).save!
  end
  
  def down
    remove_column :exemptions, :spouse
    remove_column :exemptions, :dependents
    remove_column :exemptions, :disabled_persons
    remove_column :exemptions, :basic
    add_column :exemptions, :basic_etc, :integer, :null => false, :default => 0
    
  end
end
