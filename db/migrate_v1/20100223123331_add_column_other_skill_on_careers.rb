# -*- encoding : utf-8 -*-
#
# $Id: 20100223123331_add_column_other_skill_on_careers.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnOtherSkillOnCareers < ActiveRecord::Migration
  def self.up
    add_column :careers, :other_skill, :string
  end

  def self.down
    remove_column :careers, :other_skill
  end
end
