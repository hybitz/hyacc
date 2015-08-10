class Mm::BranchesController < Base::HyaccController
  view_attribute :title => '部門管理'

  def index
  end

  def show
    @branch = load_branch
  end

  def new
    @branch = current_company.branches.build(:parent_id => params[:parent_id])
  end

  def create
    @branch = Branch.new(branch_params)

    @branch.transaction do
      @branch.save!
    end
    
    render 'common/reload'
  end

  def edit
    @branch = load_branch
  end

  def update
    @branch = load_branch
    @branch.attributes = branch_params

    @branch.transaction do
      @branch.save!
    end
    
    render 'common/reload'
  end

  private

  def branch_params
    ret = params.require(:branch)

    case action_name
    when 'create'
      ret = ret.permit(:code, :name, :parent_id)
    when 'update'
      ret = ret.permit(:name, :parent_id)
    end

    ret = ret.merge(:company_id => current_company.id)
    ret
  end

  def load_branch
    Branch.where(:company_id => current_company.id, :deleted => false).find(params[:id])
  end

end
