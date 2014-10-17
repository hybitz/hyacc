class InsertDataToExemptions < ActiveRecord::Migration
  def up
    # ICHY
    Exemptions.new(:employee_id => 1, :yyyy=>2007, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2008, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2009, :small_scale_mutual_aid => 270000, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2010, :small_scale_mutual_aid => 360000, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2011, :small_scale_mutual_aid => 360000, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2012, :small_scale_mutual_aid => 360000, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 1, :yyyy=>2013, :small_scale_mutual_aid => 360000, :basic_etc => 380000).save!
    # HIRO
    Exemptions.new(:employee_id => 2, :yyyy=>2007, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2008, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2009, :small_scale_mutual_aid => 270000, :life_insurance_premium => 43824, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2010, :small_scale_mutual_aid => 360000, :life_insurance_premium => 41434, :basic_etc => 760000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2011, :small_scale_mutual_aid => 360000, :life_insurance_premium => 50000, :basic_etc => 760000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2012, :small_scale_mutual_aid => 360000, :life_insurance_premium => 50000, :basic_etc => 380000).save!
    Exemptions.new(:employee_id => 2, :yyyy=>2013, :small_scale_mutual_aid => 360000, :life_insurance_premium => 50000, :basic_etc => 380000).save!
  end
  def down
    Exemptions.delete_all
  end
end
