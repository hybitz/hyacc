# -*- encoding : utf-8 -*-
class AddSocialExpenseNumberOfPeopleToJournalDetails < ActiveRecord::Migration
  def self.up
    add_column :journal_details, "social_expense_number_of_people", :integer, :limit => 3
  end

  def self.down
    remove_column :journal_details, "social_expense_number_of_people"
  end
end
