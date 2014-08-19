class InhabitantTax < ActiveRecord::Base
  belongs_to :employee
  
  validates :ym, presence: true
  validates :employee_id, presence: true
  validates :amount, presence: true, numericality: { only_integer: true }

  # Classメソッドを使用する
  class << self
    def new_by_array(arr)
      arr.map! do |elem|
        NKF::nkf('-S -w',elem) if elem
      end
      self.new(
                :ym => arr[0],
                :employee_id => arr[1],
                :amount => arr[2]
              )
    end
  end
end
