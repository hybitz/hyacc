class Customer < ActiveRecord::Base
  nostalgic_for :name, :formal_name

  validates :code, :uniqueness => true
  validates :name, :presence => true
  validates :formal_name, :presence => true

  after_save :reset_account_cache

  private

  def reset_account_cache
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_CUSTOMER)
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_ORDER_ENTRY)
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_ORDER_PLACEMENT)
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_INVESTMENT)
  end
end
