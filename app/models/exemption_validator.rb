class ExemptionValidator < ActiveModel::Validator
  include HyaccConst
  include HyaccErrors

  def validate(record)
    return unless record.errors.empty?
    validate_fiscal_year_and_closing_status(record)
  end

  private

  def validate_fiscal_year_and_closing_status(record)
    year = record.fiscal_year_including_december_of_yyyy
    unless year
      raise HyaccException.new( ERR_FISCAL_YEAR_NOT_EXISTS )
    else
      if year.closed? 
        raise HyaccException.new( ERR_CLOSING_STATUS_CLOSED )
      end
    end
  end

end