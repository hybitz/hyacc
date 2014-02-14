# -*- encoding : utf-8 -*-
#
# $Id: 20100223110604_change_column_skills_on_careers.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeColumnSkillsOnCareers < ActiveRecord::Migration
  def self.up
    add_column :careers, :hardware_skill, :string
    add_column :careers, :os_skill, :string
    add_column :careers, :db_skill, :string
    add_column :careers, :language_skill, :string
    
    # カラム情報を最新にする
    Career.reset_column_information
    
    Career.update_all("hardware_skill=skills")
    
    remove_column :careers, :skills
  end

  def self.down
    add_column :careers, :skills, :string
    
    # カラム情報を最新にする
    Career.reset_column_information

    Career.find(:all).each do |c|
      c.skills = ""
      c.skills << c.hardware_skill.to_s
      c.skills << "\n"
      c.skills << c.os_skill.to_s
      c.skills << "\n"
      c.skills << c.db_skill.to_s
      c.skills << "\n"
      c.skills << c.language_skill.to_s
      c.save!
    end

    remove_column :careers, :hardware_skill
    remove_column :careers, :os_skill
    remove_column :careers, :db_skill
    remove_column :careers, :language_skill
  end
end
