class Exemption < ActiveRecord::Base
  has_many :dependent_family_members, :dependent => :destroy
  belongs_to :employee
  validates :employee_id, uniqueness: {scope: [:yyyy]}
  validates_presence_of :small_scale_mutual_aid, :life_insurance_premium_old, :earthquake_insurance_premium,
        :special_tax_for_spouse, :spouse, :dependents, :disabled_persons, :basic

  accepts_nested_attributes_for :dependent_family_members, :allow_destroy => true

  def self.get(employee_id, calendar_year)
    Exemption.where(:employee_id => employee_id, :yyyy => calendar_year).first
  end

  def life_insurance_premium
    ret = 0

    # 旧契約のみで4万円を越える場合は、旧契約の限度額5万円の範囲を控除額とする
    if life_insurance_premium_old > 40_000
      ret = life_insurance_premium_old
      ret = [ret, 50_000].min
    else
      ret = life_insurance_premium_old + life_insurance_premium_new
      ret = [ret, 40_000].min
    end
    
    ret
  end

end
