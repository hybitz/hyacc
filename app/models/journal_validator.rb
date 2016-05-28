class JournalValidator < ActiveModel::Validator
  include HyaccConstants
  include HyaccErrors

  def validate(record)
    return unless record.errors.empty?
    validate_day(record)
    validate_fiscal_year(record)
    validate_tax(record)
  end

  private

  # 会計年度が存在するかチェック
  def validate_fiscal_year(record)
    unless record.fiscal_year
      raise HyaccException.new( ERR_FISCAL_YEAR_NOT_EXISTS )
    end
  end
  
  def validate_day(record)
    # 日がその年月で指定可能な範囲かどうか
    if record.day <= 0 or record.day > HyaccDateUtil.get_days_of_month( record.ym / 100, record.ym % 100 )
      record.errors[:day] << ERR_INVALID_SOMETHING
    end
  end
  
  def validate_tax(record)
    # 消費税の自動仕訳明細数をカウント
    count = record.journal_details.inject( 0 ){| sum, jd |
      jd.detail_type == DETAIL_TYPE_TAX ? sum + 1 : sum
    }
    
    # 税抜経理方式でない会計年度に消費税の自動仕訳明細が含まれているとエラー
    if count > 0
      if record.fiscal_year.tax_management_type != TAX_MANAGEMENT_TYPE_EXCLUSIVE
        raise HyaccException.new( ERR_ILLEGAL_TAX_DETAIL )
      end
    end
  end
end
