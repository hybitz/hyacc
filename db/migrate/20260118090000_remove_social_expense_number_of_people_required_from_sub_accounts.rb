class RemoveSocialExpenseNumberOfPeopleRequiredFromSubAccounts < ActiveRecord::Migration[7.2]
  def change
    remove_column :sub_accounts, :social_expense_number_of_people_required, :boolean, default: false, null: false
  end
end

