class Mm::SkillsController < Base::HyaccController
  helper_method :finder

  def index
    @skills = finder.list if params[:commit]
  end
  
  def new
    employee = current_company.employees.find(params[:employee_id])
    qualification = current_company.qualifications.find(params[:qualification_id])
    @skill = Skill.new(employee: employee, qualification: qualification)
  end
  
  def create
    @skill = Skill.new(skill_params)
    
    @skill.transaction do
      @skill.save!
    end
    
    render 'common/reload'
  end

  def edit
    @skill = Skill.find(params[:id])
  end
  
  def update
    @skill = Skill.find(params[:id])
    @skill.attributes = skill_params
    
    @skill.transaction do
      @skill.save!
    end
    
    render 'common/reload'
  end

  def destroy
    @skill = Skill.find(params[:id])

    @skill.transaction do
      @skill.destroy_logically!
    end

    render 'common/reload'
  end

  private

  def finder
    @finder ||= SkillFinder.new(finder_params)
    @finder.company_id = current_company.id
    @finder.page = params[:page]
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:skill_finder]
      params.require(:skill_finder).permit(:employee_id)
    end
  end
  
  def skill_params
    permitted = [:qualified_on]

    case action_name
    when 'create'
      permitted += [:employee_id, :qualification_id]
    end

    params.require(:skill).permit(*permitted)
  end
end
