class UpdateDisabledOnBanks < ActiveRecord::Migration
  def up
    Bank.find_each do |b|
      raise 'error' unless b.update_column(:disabled, b.deleted)
    end
  end

  def down
  end
end
