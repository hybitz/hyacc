class AccountTransferFinder < JournalFinder
  attr_accessor :to_account_id
  attr_accessor :to_sub_account_id

  def initialize(user)
    super(user)
    @to_account_id = 0
    @to_sub_account_id = 0
  end
end
