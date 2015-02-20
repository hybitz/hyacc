class WithholdingSlipController < Base::HyaccController
  include JournalUtil

  view_attribute :title => '源泉徴収'
  view_attribute :finder, :class=>WithholdingSlipFinder
  view_attribute :cy_list
  view_attribute :report_types
  view_attribute :employees

  def index
    return unless finder.commit
    begin
      case finder.report_type
      when REPORT_TYPE_WITHHOLDING_SUMMARY
        render_withholding_summary
      when REPORT_TYPE_WITHHOLDING_DETAILS
         if validate_params_details
           render_withholding_details
         else
           render :index
         end
      end
    rescue => e
      handle(e)
      render :index
    end
  end

  private

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
    if logic.has_exemption
      @data = logic.get_withholding_info
      render :withholding_details
    else
      @finder = finder
      render :no_exemption
    end
  end
end
