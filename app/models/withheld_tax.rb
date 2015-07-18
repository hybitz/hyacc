class WithheldTax < TaxJp::WithheldTax
  
  def self.find_by_date_and_pay_and_dependent(date, pay, dependent)
    ret = 0

    case dependent
    when 0, 1, 2, 3, 4, 5, 6, 7
      withheld_tax = find_by_date_and_salary(date, pay)
      if withheld_tax
        ret = withheld_tax.__send__("dependent_#{dependent}")
      end
    else
      raise 'TODO 7人以上は1人を超えるごとに¥1,580/¥1,610＋'
    end

    ret
  end

end
