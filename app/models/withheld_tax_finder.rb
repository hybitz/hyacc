class WithheldTaxFinder < Base::Finder

  attr_accessor :after_deduction
  
  # 初期化
  def initialize( user )
    super( user )
    @ym = Time.new.strftime("%Y%m")
  end
  
  def setup_from_params( params )
    return unless params

    super( params )
    @after_deduction = params[:after_deduction]
  end
  
  def list
    sql = SqlBuilder.new
    sql.append('apply_start_ym <= ? and apply_end_ym >= ?', self.ym, self.ym) if self.ym.present?

    amount = @after_deduction.to_s.gsub(/,/, '')
    if amount.present?
      sql.append('and') if sql.to_a.present?
      sql.append('pay_range_above <= ? and pay_range_under > ?', amount, amount)
    end
    
    WithheldTax.where(sql.to_a)
  end
end
