class AddColumnShowDetailsOnUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :show_details, :boolean, :null=>false, :default=>true
  end

  def self.down
    remove_column :users, :show_details
  end
end
