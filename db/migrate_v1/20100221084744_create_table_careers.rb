# -*- encoding : utf-8 -*-
#
# $Id: 20100221084744_create_table_careers.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableCareers < ActiveRecord::Migration
  def self.up
    create_table :careers do |t|
      t.integer :employee_id, :null=>false
      t.date :start_from, :null=>false
      t.date :end_to, :null=>false
      t.integer :customer_id, :null=>false
      t.string :customer_name, :null=>false
      t.string :project_name, :null=>false
      t.string :description
      t.string :project_size
      t.string :role
      t.string :process
      t.string :skills
      t.timestamps
    end
  end

  def self.down
    drop_table :careers
  end
end
