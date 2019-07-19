module Companies

  def company
    unless @_company
      @_company = Company.not_deleted.first
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

  def company_params(options = {})
    {
      admin_email: 'admin@example.com',
      business_type_id: BusinessType.first.id
    }
  end
  
  def new_company(options = {})
    Company.new(company_params.merge(founded_date: Date.today - rand(3).years, name: 'テスト会社', start_month_of_fiscal_year: rand(12) + 1))
  end
  
  def create_company(options = {})
    ret = new_company(options)
    assert ret.save, ret.errors.full_messages
    ret
  end
end