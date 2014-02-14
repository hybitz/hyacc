# -*- encoding : utf-8 -*-
class AddColumnIsHeadOfficeToBranches < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :branches, "is_head_office", :boolean, :null=>false, :default=>false
    
    # カラム情報を最新にする
    Branch.reset_column_information

    # 本社に本店フラグを立てる
    head_office = Branch.find_by_code('101')
    head_office.is_head_office = true
    head_office.save!
  end

  def self.down
    remove_column :branches, "is_head_office"
  end
end
