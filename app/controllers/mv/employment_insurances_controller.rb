class Mv::EmploymentInsurancesController < Base::HyaccController
  helper_method :finder

  def index
    @list = finder.list
  end

  private

  def finder
    unless @finder
      @finder = EmploymentInsuranceFinder.new
    end

    @finder
  end
end
