class WithheldTaxFinder < Daddy::Model

  def ym
    self['ym'] ||= Date.today.strftime("%Y-%m")
  end

  def ym_int
    ym.gsub('-', '')
  end

  def date
    Date.strptime(ym + '-01', '%Y-%m-%d')
  end

  def list
    TaxJp::WithheldTax.find_by_date(date)
  end
end
