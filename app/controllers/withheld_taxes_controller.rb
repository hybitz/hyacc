class WithheldTaxesController < Base::BasicMasterController
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :title => '源泉徴収税'

  private

  def withheld_tax_params
    params.require(:withheld_tax).permit(
        :apply_start_ym, :apply_end_ym, :pay_range_above, :pay_range_under,
        :no_dependent, :one_dependent, :two_dependent, :three_dependent, :four_dependent, :five_dependent, 
        :six_dependent, :seven_dependent)
  end

end
