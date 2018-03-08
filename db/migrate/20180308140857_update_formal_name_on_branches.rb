class UpdateFormalNameOnBranches < ActiveRecord::Migration[5.1]
  def up
    Branch.update_all(['formal_name = name'])
  end
  
  def down
  end
end
