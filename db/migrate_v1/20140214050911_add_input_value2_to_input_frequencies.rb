class AddInputValue2ToInputFrequencies < ActiveRecord::Migration
  def up
    remove_index :input_frequencies, :name=>'index_input_frequencies_for_unique_key'

    change_column :input_frequencies, :input_value, :string, :limit => 30, :default => ''
    add_column :input_frequencies, :input_value2, :string, :limit => 30, :default => ''
    
    add_index :input_frequencies, [:user_id, :input_type, :input_value, :input_value2], :unique=>true,
      :name=>'index_input_frequencies_for_unique_key'
  end

  def down
    remove_index :input_frequencies, :name=>'index_input_frequencies_for_unique_key'
    
    remove_column :input_frequencies, :input_value2
    change_column :input_frequencies, :input_value, :string, :limit => 255
    
    add_index :input_frequencies, [:user_id, :input_type, :input_value], :unique=>true,
      :name=>'index_input_frequencies_for_unique_key'
  end
end
