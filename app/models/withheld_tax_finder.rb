class WithheldTaxFinder < Daddy::Model

  def ym
    self['ym'] ||= Date.today.strftime("%Y-%m")
  end

  def ym_int
    ym.gsub('-', '')
  end
  
  def list
    sql = SqlBuilder.new
    sql.append('apply_start_ym <= ? and apply_end_ym >= ?', self.ym_int, self.ym_int)

    amount = @after_deduction.to_s.gsub(/,/, '')
    if amount.present?
      sql.append('and') if sql.to_a.present?
      sql.append('pay_range_above <= ? and pay_range_under > ?', amount, amount)
    end
    
    WithheldTax.where(sql.to_a)
  end
end
