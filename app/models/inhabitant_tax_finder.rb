class InhabitantTaxFinder
  include ActiveModel::Model

  attr_accessor :year

  def year
    unless @year.present?
      today = Date.today
      yyyy = today.year
      yyyymm = today.strftime("%Y%m").to_i
      @year = yyyy + yyyymm/(yyyy.to_s + '06').to_i - 1
    end

    @year.to_i
  end
  
  def list
    sql = SqlBuilder.new
    sql.append('ym >= ? and ym <= ?', year.to_s + '06', (year + 1).to_s + '05')
    InhabitantTax.where(sql.to_a).order('employee_id, ym')
  end

end
