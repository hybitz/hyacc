class Investment < ApplicationRecord
  include HyaccErrors

  belongs_to :customer
  belongs_to :bank_account
  has_one :journal, dependent: :destroy

  validates :yyyymmdd, presence: true, date: true
  validates :buying_or_selling, :presence => true
  validates_numericality_of :shares, :greater_than => 0
  validates_numericality_of :trading_value, :greater_than_or_equal_to => 0
  validates_numericality_of :charges, :greater_than_than_or_equal_to => 0

  attr_accessor :yyyymmdd

  before_save :set_ym_and_day
  before_destroy :ensure_journal_is_investment_slip
  after_find :set_yyyymmdd

  def deal_date
    Date.parse(yyyymmdd)
  end

  def buying?
    buying_or_selling == SECURITIES_TRANSACTION_TYPE_BUYING
  end

  def selling?
    buying_or_selling == SECURITIES_TRANSACTION_TYPE_SELLING
  end

  def yyyymmdd_before_type_cast
    yyyymmdd
  end

  private

  def ensure_journal_is_investment_slip
    jh = journal
    return unless jh.present?
    return if jh.slip_type == SLIP_TYPE_INVESTMENT

    raise HyaccException.new(ERR_INVESTMENT_UNLINK_REQUIRED)
  end

  def set_ym_and_day
    split = self.yyyymmdd.split("-")
    self.ym = split[0..1].join
    self.day = split[2]
  end

  def set_yyyymmdd
    self.yyyymmdd = self.ym.to_s[0,4] + '-' + self.ym.to_s[4,2] + '-' + self.day.to_s.rjust(2, '0')
  end
end
