class Mm::QualificationsController < Base::HyaccController
  
  def index
    @qualifications = current_company.qualifications.paginate(page: params[:page] || 1, per_page: 10)
  end

  def new
    @qualification = current_company.qualifications.build
  end
  
  def edit
    @qualification = current_company.qualifications.find(params[:id])
  end

  def create
    @qualification = current_company.qualifications.build(qualification_params)

    begin
      @qualification.transaction do
        @qualification.save!
      end

      flash[:notice] = "#{@qualification.name} を登録しました。"
      render 'common/reload'

    rescue => e
      handle(e)
      render :new
    end
  end

  def update
    @qualification = current_company.qualifications.find(params[:id])
    @qualification.attributes = qualification_params

    begin
      @qualification.transaction do
        @qualification.save!
      end

      flash[:notice] = "#{@qualification.name} を更新しました。"
      render 'common/reload'
      
    rescue => e
      handle(e)
      render :edit
    end
  end

  def destroy
    @qualification = current_company.qualifications.find(params[:id])

    begin
      @qualification.transaction do
        @qualification.destroy_logically!
      end

      flash[:notice] = "#{@qualification.name} を削除しました。"

    rescue => e
      handle(e)
    end

    redirect_to action: 'index'
  end

  private

  def qualification_params
    permitted = [
      :name, :allowance
    ]

    ret = params.require(:qualification).permit(*permitted)

    case action_name
    when 'create'
      ret = ret.merge(company_id: current_company.id)
    end

    ret
  end

end
