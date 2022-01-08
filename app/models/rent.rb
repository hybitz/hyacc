class Rent < ApplicationRecord
  belongs_to :customer

  validates_presence_of :rent_type, :usage_type, :status, :name, message: "は必須です。"
  validates :start_from, presence: true
  validates_format_of :zip_code, :with=>/[0-9]{7}/, :allow_nil=>true, :message=>'は数字7桁で入力してください。'

  validate :validate_end_to

  attr_accessor :total_amount
  attr_accessor :remarks

  def code
    name
  end

  private

  def validate_end_to
    if start_from.present? && end_to.present? && start_from > end_to
      errors.add(:end_to, "は契約開始日以降を指定してください。")
    end
  end
  
end
