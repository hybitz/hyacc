class Mm::BranchesController < Base::HyaccController
  view_attribute :title => '部門管理'

  def index
  end

  def show
    @branch = Branch.find(params[:id])
  end

end
