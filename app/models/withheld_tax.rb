class WithheldTax < ActiveRecord::Base
  validates_presence_of :apply_start_ym, :apply_end_ym, :message=>"を入力して下さい。"
  validates_format_of :apply_start_ym, :apply_end_ym, :with => /^[0-9]{6}$/, :message=>"は数値６桁で入力して下さい。"
  validates_format_of :pay_range_above, :pay_range_under,
                      :no_dependent, :one_dependent,
                      :two_dependent, :three_dependent,
                      :four_dependent, :five_dependent,
                      :six_dependent, :seven_dependent,
                      :with => /^[0-9]{1,}$/, :message=>"は数値で入力して下さい。"
  
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
                :pay_range_above => arr[2],
                :pay_range_under => arr[3],
                :no_dependent => arr[4],
                :one_dependent => arr[5],
                :two_dependent => arr[6],
                :three_dependent => arr[7],
                :four_dependent => arr[8],
                :five_dependent => arr[9],
                :six_dependent => arr[10],
                :seven_dependent => arr[11]
              )
    end
  end
  
  def WithheldTax.find_by_ym_and_pay(ym, pay)
    sql = SqlBuilder.new
    sql.append('apply_start_ym <= ? and apply_end_ym >= ?', ym, ym)
    sql.append('and pay_range_under > ? and pay_range_above <= ?', pay, pay)

    ret = WithheldTax.where(sql.to_a).first
    ret ||= WithheldTax.new.init
    ret
  end
  
  def init
    self.no_dependent = 0
    self.one_dependent = 0
    self.two_dependent = 0
    self.three_dependent = 0
    self.four_dependent = 0
    self.five_dependent = 0
    self.six_dependent = 0
    self.seven_dependent = 0
    self
  end
end
