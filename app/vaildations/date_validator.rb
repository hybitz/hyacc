class DateValidator < ActiveModel::EachValidator
  
  def validate_each(record, attribute, value)
    value_before_type_cast = record.__send__("#{attribute}_before_type_cast")

    unless value_before_type_cast =~ /\A[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}\z/
      record.errors[attribute] << 'は YYYY-MM-DD 形式で入力して下さい。'
      return
    end

    unless value
      record.errors[attribute] << 'は存在する日付を入力して下さい。'
      return
    end
  end

end
