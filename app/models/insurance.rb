class Insurance < ActiveRecord::Base
  include HyaccConstants
  
  validates_presence_of :apply_start_ym, :apply_end_ym, :message=>"を入力して下さい。"
  validates_format_of :apply_start_ym, :apply_end_ym, :with => /^[0-9]{6}$/, :message=>"は数値６桁で入力して下さい。"
  validates_format_of :pay_range_above, :pay_range_under, :grade,
                      :monthly_earnings, :daily_earnings,
                      :with => /^[0-9]{1,}$/, :message=>"は数値で入力して下さい。"
  validates_format_of :health_insurance_all_care, :health_insurance_half_care,
                      :health_insurance_all, :health_insurance_half,
                      :welfare_pension_insurance_all, :welfare_pension_insurance_half,
                      :with => /^[0-9.]{1,}$/, :message=>"は数値で入力して下さい"
  
  # Classメソッドを使用する
  class << self
    #set_field_names :apply_start_ym=>'適用開始日'
    def new_by_array(arr)
      arr.map! do |elem|  
        NKF::nkf('-S -w',elem) if elem
      end
      
      #return nil unless valid_data?(arr)
      
      self.new(
                :apply_start_ym => arr[0],
                :apply_end_ym => arr[1],
                :grade => arr[2],
                :pay_range_above => arr[3],
                :pay_range_under => arr[4],
                :monthly_earnings => arr[5],
                :daily_earnings => arr[6],
                :health_insurance_all => arr[7],
                :health_insurance_half => arr[8],
                :health_insurance_all_care => arr[9],
                :health_insurance_half_care => arr[10],
                :welfare_pension_insurance_all => arr[11],
                :welfare_pension_insurance_half => arr[12]
              )
    end
  end
  
  def Insurance.find_by_ym_and_pay(ym = nil, pay = nil)
    # 月別情報を検索
    conditions = []
    conditions[0] = "apply_end_ym >= ? and apply_start_ym <= ?"
    conditions << ym
    conditions << ym
    conditions[0] << " and pay_range_under > ? and pay_range_above <= ? "
    conditions << pay
    conditions << pay
    insurance = Insurance.find(:first, :conditions=>conditions)
    if insurance == nil
      return Insurance.new.init
    end
    return insurance
  end
  
  def init
    self.grade = 0
    self.monthly_earnings = 0
    self.daily_earnings = 0
    self.health_insurance_all = 0
    self.health_insurance_half = 0
    self.health_insurance_all_care = 0
    self.health_insurance_half_care = 0
    self.welfare_pension_insurance_all = 0
    self.welfare_pension_insurance_half = 0
    return self
  end
  
end
