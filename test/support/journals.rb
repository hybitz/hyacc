module Journals
  def journal
    unless @_journal
      assert c = Company.first
      assert fy = c.current_fiscal_year
      assert @_journal = Journal.where(:fiscal_year_id => fy.id).first
    end
    @_journal
  end

  
end