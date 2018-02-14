class Rent < ApplicationRecord
  include HyaccConstants
  
  belongs_to :customer

  validates_presence_of :rent_type, :usage_type, :ymd_start, :status, :name, :message => "は必須です。"
  validates_format_of :ymd_start, :ymd_end, :allow_nil=>true, :with=>/[0-9]{8}/, :message=>"は数値８桁で入力して下さい。"
  validates_format_of :zip_code, :with=>/[0-9]{7}/, :allow_nil=>true, :message=>'は数字7桁で入力してください。'

  validate :validate_ymd_end

  attr_accessor :total_amount
  attr_accessor :remarks

  def code
    name
  end

  private

  def validate_ymd_end
    if ymd_end.present? && ymd_start.present? && ymd_start > ymd_end
      errors.add(:ymd_end, "は契約開始日以降を指定してください。")
    end
  end
  
end
