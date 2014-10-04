class BankOffice < ActiveRecord::Base
  belongs_to :bank
  LABELS = {:name => '営業店名称', :code => '営業店コード', :deleted => '状態'}
  def self.label(col)
    LABELS[col]
  end
end
