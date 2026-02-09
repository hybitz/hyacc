class Mm::CareersController < Base::HyaccController
  view_attribute :customers, :conditions => ['is_order_entry=?', true]

  helper_method :finder

  def index
    @careers = finder.list
  end

  def new
    @c = Career.new
  end

  def create
    @c = Career.new(career_params)
    begin
      @c.transaction do
        @c.save!
      end

      flash[:notice] = '業務経歴を追加しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render 'new'
    end
  end

  def edit
    @c = Career.find(params[:id])
  end

  def update
    @c = Career.find(params[:id])

    begin
      @c.transaction do
        @c.update!(career_params)
      end

      flash[:notice] = '業務経歴を更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render 'edit'
    end
  end
  
  def destroy
    c = Career.find(params[:id])
    c.destroy
    flash[:notice] = '業務経歴を削除しました。'
    redirect_to :action => 'index'
  end

  private

  def finder
    @finder ||= CareerFinder.new(finder_params)
    @finder.company_id = current_company.id
    @finder.page = params[:page]
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit(
          :employee_id
        )
    end
  end

  def career_params
    params.require(:career).permit(
        :employee_id, :start_from, :end_to, :customer_id, :project_name, :description, :project_size, 
        :role, :process, :hardware_skill, :os_skill, :db_skill, :language_skill, :other_skill)
  end

end
