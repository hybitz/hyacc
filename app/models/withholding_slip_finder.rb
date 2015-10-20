class WithholdingSlipFinder < Base::Finder
  attr_reader :company_id
  attr_reader :report_type
  attr_reader :report_style
  attr_reader :calendar_year
  attr_reader :employee_id
  
  def initialize(user)
    super(user)
    @company_id = user.company.id
  end
  
  def setup_from_params( params )
    super(params)
    if params
      @report_type = params[:report_type].to_i
      @report_style = params[:report_style].to_i
      @fiscal_year = params[:calendar_year].to_i
      @employee_id = params[:employee_id].to_i
    end
  end

end
