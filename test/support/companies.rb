module Companies

  def company
    unless @_company
      assert @_company = Company.not_deleted.first
    end
    @_company
  end

  def company_of_tax_general
    unless @_company_of_tax_general
      Company.find_each do |c|
        if c.tax_general?
          @_company_of_tax_general = c
          break
        end
      end
    end
    @_company_of_tax_general
  end

  def company_of_tax_simplified
    unless @_company_of_tax_simplified
      Company.find_each do |c|
        if c.tax_simplified?
          @_company_of_tax_simplified = c
          break
        end
      end
    end
    @_company_of_tax_simplified
  end

  def company_of_tax_inclusive
    unless @_company_of_tax_inclusive
      Company.find_each do |c|
        if c.tax_inclusive?
          @_company_of_tax_inclusive = c
          break
        end
      end
    end
    @_company_of_tax_inclusive
  end

  def valid_company_params
    {
      :admin_email => 'admin@example.com',
      :business_type_id => BusinessType.first.id
    }
  end
end