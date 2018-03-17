class Investment < ApplicationRecord
  belongs_to :customer
  belongs_to :bank_account
  belongs_to :journal_detail

  validates :yyyymmdd, :presence => true, format: {
    with: /\d{4}-\d{2}-\d{2}/,
    message: 'のフォーマットが不正です'
  }
  validates :buying_or_selling, :presence => true
  validates_numericality_of :shares, :greater_than => 0
  validates_numericality_of :trading_value, :greater_than_or_equal_to => 0
  validates_numericality_of :charges, :greater_than_than_or_equal_to => 0
  
  attr_accessor :buying_or_selling
  attr_accessor :yyyymmdd
  
  before_save :set_ym_and_day
  before_save :set_trading_value
  after_find :set_buying_or_sellng
  after_find :set_yyyymmdd

  def deal_date
    Date.parse(yyyymmdd)
  end

  def buying?
    buying_or_selling == '1'
  end

  def selling?
    buying_or_selling == '0'
  end

  private

  def set_ym_and_day
    split = self.yyyymmdd.split("-")
    self.ym = split[0..1].join
    self.day = split[2]
  end

  def set_yyyymmdd
    self.yyyymmdd = self.ym.to_s[0,4] + '-' + self.ym.to_s[4,2] + '-' + self.day.to_s
  end

  def set_trading_value
    if buying_or_selling == '0'
      self.shares = self.shares * -1
      self.trading_value = self.trading_value * -1
    end
  end

  def set_buying_or_sellng
    self.buying_or_selling = '1'
    if self.trading_value < 0 || self.shares < 0
      self.shares = self.shares * -1
      self.trading_value = self.trading_value * -1
      self.buying_or_selling = '0'
    end
  end
end
