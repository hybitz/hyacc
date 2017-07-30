class UpdateAccountTypeOnAccount4221 < ActiveRecord::Migration[5.0]
  include HyaccConstants

  def up
    a = Account.find_by_code('4221')
    if a
      a.update(account_type: ACCOUNT_TYPE_PROFIT)
    end
  end

  def down
  end
end
