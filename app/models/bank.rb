class Bank < ActiveRecord::Base
  include HyaccConstants
  LABELS = {:name => '金融機関名称', :code => '金融機関コード', :deleted => '状態'}

  validates :code, :presence => true

  has_many :bank_offices
  accepts_nested_attributes_for :bank_offices

  def self.label(col)
    LABELS[col]
  end
end
