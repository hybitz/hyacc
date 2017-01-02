class WithholdingSlipController < Base::HyaccController
  view_attribute :title => '源泉徴収'
  helper_method :finder

  def index
    begin
      case finder.report_type.to_i
      when REPORT_TYPE_WITHHOLDING_SUMMARY
        render_withholding_summary
      when REPORT_TYPE_WITHHOLDING_DETAILS
        if validate_params_details
          render_withholding_details
        else
          render :index
        end
      when REPORT_TYPE_WITHHOLDING_CALC
        render_withholding_calc
      else
        render :index
      end
    rescue => e
      handle(e)
      render :index
    end
  end

  private

  def finder
    if @finder.nil?
      @finder = WithholdingSlipFinder.new(params[:finder])
      @finder.company_id = current_company.id
      @finder.calendar_year ||= Date.today.year
      @finder.employee_id ||= current_user.employee.id
    end

    @finder
  end

  def validate_params_details
    if @finder.employee_id == 0
      flash[:notice] = '従業員を選択してください。'
      return false
    end
    return true
  end
  
  def render_withholding_summary
    logic = Reports::WithholdingSummaryLogic.new(finder)
    @data = logic.get_withholding_info
    render :withholding_summary
  end
  
  def render_withholding_details
    logic = Reports::WithholdingDetailLogic.new(finder)

    unless logic.has_exemption?
      @finder = finder
      render :no_exemption and return
    end

    @data = logic.get_withholding_info
    render :withholding_details
  end
  
  def render_withholding_calc
    logic = Reports::WithholdingCalcLogic.new(finder)
    @data = logic.get_withholding_info
    render :withholding_calc
  end
end
