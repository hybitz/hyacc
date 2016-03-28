class Investment < ActiveRecord::Base
  belongs_to :customer
  belongs_to :bank_account
  belongs_to :journal_detail

  validates :yyyymmdd, :presence => true, format: {
    with: /\d{4}-\d{2}-\d{2}/,
    message: 'のフォーマットが不正です'
  }
  validates :buying_or_selling, :presence => true
  validates_numericality_of :shares, :greater_than => 0
  validates_numericality_of :trading_value, :greater_than => 0
  validates_numericality_of :charges, :greater_than => 0
  
  attr_accessor :buying_or_selling
  attr_accessor :yyyymmdd
  attr_accessor :charges
  
  before_save :set_ym_and_day
  before_save :set_trading_value
  
  def set_ym_and_day
    split = self.yyyymmdd.split("-")
    self.ym = split[0..1].join
    self.day = split[2]
  end
  
  def set_trading_value
    if buying_or_selling == "0"
      self.shares = self.shares * -1
      self.trading_value = self.trading_value * -1
    end
  end
    
end
