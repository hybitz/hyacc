class AddColumnNumOfHouseLoanOnExemptions < ActiveRecord::Migration[5.0]
  def change
    add_column :exemptions, :mortgage_deduction, :integer
    add_column :exemptions, :num_of_house_loan, :integer
    add_column :exemptions, :max_mortgage_deduction, :integer
    add_column :exemptions, :date_of_start_living_1, :date
    add_column :exemptions, :mortgage_deduction_code_1, :string
    add_column :exemptions, :year_end_balance_1, :integer
    add_column :exemptions, :date_of_start_living_2, :date
    add_column :exemptions, :mortgage_deduction_code_2, :string
    add_column :exemptions, :year_end_balance_2, :integer
    remove_column :exemptions, :house_loan, :integer
    remove_column :exemptions, :small_scale_mutual_aid, :integer
    remove_column :exemptions, :life_insurance_premium_new, :integer
    remove_column :exemptions, :life_insurance_premium_old, :integer
    remove_column :exemptions, :earthquake_insurance_premium, :integer
    remove_column :exemptions, :special_tax_for_spouse, :integer
    remove_column :exemptions, :dependents, :integer
    remove_column :exemptions, :spouse, :integer
    remove_column :exemptions, :disabled_persons, :integer
    remove_column :exemptions, :basic, :integer
    add_column :exemptions, :small_scale_mutual_aid, :integer
    add_column :exemptions, :life_insurance_premium_new, :integer
    add_column :exemptions, :life_insurance_premium_old, :integer
    add_column :exemptions, :earthquake_insurance_premium, :integer
    add_column :exemptions, :special_tax_for_spouse, :integer
    add_column :exemptions, :dependents, :integer
    add_column :exemptions, :spouse, :integer
    add_column :exemptions, :disabled_persons, :integer
    add_column :exemptions, :basic, :integer
    
    # データ戻し
    data = [{:employee_id => 1, :yyyy => 2009, :small_scale_mutual_aid => 270000, :life_insurance_premium_new => nil, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 1, :yyyy => 2010, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 1, :yyyy => 2011, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 1, :yyyy => 2012, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 1, :yyyy => 2013, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 1, :yyyy => 2014, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 1, :yyyy => 2015, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 1, :yyyy => 2016, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => 259360, :life_insurance_premium_old => nil, :spouse => nil, :dependents => nil},
            {:employee_id => 2, :yyyy => 2009, :small_scale_mutual_aid => 270000, :life_insurance_premium_new => nil, :life_insurance_premium_old => 43824, :spouse => nil, :dependents => nil},
            {:employee_id => 2, :yyyy => 2010, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => 41434, :spouse => nil, :dependents => 380000},
            {:employee_id => 2, :yyyy => 2011, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => 50000, :spouse => 380000, :dependents => nil},
            {:employee_id => 2, :yyyy => 2012, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => 50000, :spouse => nil, :dependents => nil},
            {:employee_id => 2, :yyyy => 2013, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => 50000, :spouse => nil, :dependents => nil},
            {:employee_id => 2, :yyyy => 2014, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => 161424, :spouse => nil, :dependents => nil},
            {:employee_id => 2, :yyyy => 2015, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => nil, :life_insurance_premium_old => 161424, :spouse => nil, :dependents => nil},
            {:employee_id => 2, :yyyy => 2016, :small_scale_mutual_aid => 360000, :life_insurance_premium_new => 20595, :life_insurance_premium_old => 161424, :spouse => nil, :dependents => nil}
              ]

    Exemption.transaction do
      Exemption.update_all(:basic => 380000)
      data.each do |emp|
        e = Exemption.where(:employee_id => emp[:employee_id], :yyyy => emp[:yyyy]).first
        e.small_scale_mutual_aid = emp[:small_scale_mutual_aid]
        e.life_insurance_premium_new = emp[:life_insurance_premium_new]
        e.life_insurance_premium_old = emp[:life_insurance_premium_old]
        e.spouse = emp[:spouse]
        e.dependents = emp[:dependents]
        e.save!
      end
    end
  end
end
