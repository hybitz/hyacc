# -*- encoding : utf-8 -*-
class ChangeColumnHealthInsuranceOnInsurances < ActiveRecord::Migration
  def self.up
    change_column :insurances, :health_insurance_all, :float
    change_column :insurances, :health_insurance_half, :float
  end

  def self.down
    change_column :insurances, :health_insurance_all, :integer
    change_column :insurances, :health_insurance_half, :integer
  end
end
