class InhabitantTaxFinder < Base::Finder
  attr_accessor :year

  # 初期化
  def initialize( user )
    super( user )
    yyyy = Time.new.strftime("%Y").to_i
    yyyymm = Time.new.strftime("%Y%m").to_i
    @year = yyyy + yyyymm/(yyyy.to_s + '06').to_i - 1
  end
  
  def setup_from_params( params )
    return unless params
    super( params )
    @year = params[:year].to_i
  end
  
  def list
    raise HyaccException.new("年は必須です。") if @year == 0

    sql = SqlBuilder.new
    sql.append('ym >= ? and ym <= ?', @year.to_s + '06', (@year + 1).to_s + '05')
    InhabitantTax.where(sql.to_a).order('employee_id, ym')
  end

end
