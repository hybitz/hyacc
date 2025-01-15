class ExemptionValidator < ActiveModel::Validator
  include HyaccConst
  include HyaccErrors

  def validate(record)
    return unless record.errors.empty?
    validate_fiscal_year_and_closing_status(record)
  end

  private

  def validate_fiscal_year_and_closing_status(record)
    fiscal_year = record.fiscal_year
    unless fiscal_year
      raise HyaccException.new( ERR_FISCAL_YEAR_NOT_EXISTS )
    else
      if fiscal_year.closing_status == CLOSING_STATUS_CLOSED 
        raise HyaccException.new( ERR_CLOSING_STATUS_CLOSED )
      end
    end
  end

end