class Career < ApplicationRecord
  belongs_to :employee
  belongs_to :customer

  validates :project_name, :presence => true

  before_save :update_names

  # マスタの名称を明細自身に設定する
  def update_names
    self.customer_name = customer.formal_name_on(end_to)
  end
  
  def duration_ym
    duration = (end_to_or_today - start_from).to_i
    return duration/365, duration%365/31 + (duration%365%31 > 0 ? 1 : 0)
  end
  
  def is_up_to_today
    today = Date.today
    end_to - today > 0
  end
  
  def end_to_or_today
    if is_up_to_today
      Date.today
    else
      end_to
    end
  end
end
