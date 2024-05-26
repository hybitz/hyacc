class Asset < ApplicationRecord
  belongs_to :account
  belongs_to :sub_account, optional: true
  belongs_to :branch
  belongs_to :journal_detail

  has_many :depreciations, -> {order(:fiscal_year)}, inverse_of: :asset, dependent: :destroy
  accepts_nested_attributes_for :depreciations

  validate :validate_durable_years, :validate_depreciation_limit
  validates_presence_of :code, :name, :account_id, :branch_id, :ym, :day, :status
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  before_save :update_start_and_end_fiscal_year

  def date
    Date.new(year, month, day)
  end

  def year
    ym / 100
  end

  def month
    ym % 100
  end

  def amount_at_start(fiscal_year)
    if depreciations.present?
      depreciations.find{|d| d.fiscal_year == fiscal_year.to_i }.amount_at_start
    else
      amount
    end
  end

  def amount_at_end(fiscal_year)
    if depreciations.present?
      depreciations.find{|d| d.fiscal_year == fiscal_year.to_i }.amount_at_end
    else
      amount
    end
  end

  def durable_years_required?
    [DEPRECIATION_METHOD_FIXED_AMOUNT, DEPRECIATION_METHOD_FIXED_RATE].include?(depreciation_method)
  end

  def depreciation_method_name
    DEPRECIATION_METHODS[depreciation_method]
  end
  
  def has_depreciations?
    depreciations.present?
  end
  
  def status_name
    ASSET_STATUS[status]
  end
  
  def status_created?
    self.status == ASSET_STATUS_CREATED
  end

  def status_waiting?
    self.status == ASSET_STATUS_WAITING
  end
  
  def status_depreciating?
    self.status == ASSET_STATUS_DEPRECIATING
  end

  def status_depreciated?
    self.status == ASSET_STATUS_DEPRECIATED
  end
  
  # 償却開始年度、償却終了年度を更新する
  def update_start_and_end_fiscal_year
    if depreciations.size > 0
      self.start_fiscal_year = depreciations.first.fiscal_year
      self.end_fiscal_year = depreciations.last.fiscal_year
    else
      self.start_fiscal_year = branch.company.get_fiscal_year_int(ym)
      self.end_fiscal_year = start_fiscal_year
    end
  end
  
  def durable_years_required?
    depreciation_method != DEPRECIATION_METHOD_LUMP
  end
  
  def validate_durable_years
    unless status_created?
      if durable_years_required?
        if durable_years.nil?
          errors.add(:durable_years, :empty)
        elsif durable_years.to_i <= 0
          errors.add(:durable_years)
        end
      end
    end
  end

  def validate_depreciation_limit
    unless status_created?
      if depreciation_limit.nil?
        errors.add(:depreciation_limit, :empty)
      elsif depreciation_limit.to_i < 0
        errors.add(:depreciation_limit)
      end
    end
  end
end
