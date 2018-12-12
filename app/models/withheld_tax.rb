class WithheldTax
  
  def self.find_by_date_and_salary_and_dependent(date, salary, dependent)
    ret = 0

    case dependent.to_i
    when 0, 1, 2, 3, 4, 5, 6, 7
      withheld_tax = TaxJp::WithheldTax.find_by_date_and_salary(date, salary)
      if withheld_tax
        ret = withheld_tax.__send__("dependent_#{dependent}")
      end
    else
      raise 'TODO 7人以上は1人を超えるごとに¥1,580/¥1,610＋'
    end

    ret
  end

  def self.find_bonus_tax_ratio_by_date_and_salary_and_dependent(date, previous_salary, dependent)
    ret = 0

    withheld_tax = TaxJp::WithheldTaxes::Bonus.find_by_date_and_salary_and_dependant(date, previous_salary, dependent)
    if withheld_tax
      ret = withheld_tax.tax_ratio
    end

    ret
  end

end
