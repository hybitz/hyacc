class Mm::BranchesController < Base::HyaccController

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
    
    flash[:notice] = '部門を追加しました。'
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

  def destroy
    @branch = load_branch

    @branch.transaction do
      @branch.destroy_logically!
    end

    render 'common/reload'
  end

  private

  def branch_params
    permitted = [
      :formal_name, :name,
      :business_office_id, :business_office_id_effective_at,
      :business_office_ids_attributes => [:id, :_destroy]
    ]

    ret = params.require(:branch)

    case action_name
    when 'create'
      ret = ret.permit(permitted, :code, :parent_id)
    when 'update'
      ret = ret.permit(permitted)
    end

    ret = ret.merge(company_id: current_company.id)
    ret
  end

  def load_branch
    Branch.where(company_id: current_company.id, deleted: false).find(params[:id])
  end

end
