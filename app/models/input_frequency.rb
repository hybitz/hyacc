class InputFrequency < ApplicationRecord
  belongs_to :user

  def self.latest(user_id, input_type)
    where(:user_id => user_id, :input_type => input_type).order('frequency desc')
  end

  def self.save_input_frequency(user_id, input_type, input_value="", input_value2="")
    f = InputFrequency.where(:user_id => user_id, :input_type => input_type, :input_value => input_value, :input_value2 => input_value2).first

    unless f
      f = InputFrequency.new
      f.user_id = user_id
      f.input_type = input_type
      f.input_value = input_value.to_s
      f.input_value2 = input_value2.to_s
      f.frequency = 0
    end

    f.frequency += 1
    f.save!
  end

end
