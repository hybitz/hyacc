class Sequence < ApplicationRecord

  def self.create_sequence(name, section=nil)
    Sequence.new(:name=>name.to_s, :section=>section).save!
  end
  
  def self.next_value(name, section=nil)
    if section
      sql = "update sequences set value=last_insert_id(value+1) where name='#{name.to_s}' and section='#{section.to_s}'"
    else
      sql = "update sequences set value=last_insert_id(value+1) where name='#{name.to_s}'"
    end
    
    con = Sequence.connection
    con.update(sql)
    con.select_one("select last_insert_id() as next_value")['next_value'].to_i
  end
end
