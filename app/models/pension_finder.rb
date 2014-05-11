class PensionFinder < Base::Finder
  include JournalUtil

  attr_accessor :ym
  attr_accessor :base_salary
  attr_accessor :grade_start
  attr_accessor :grade_end
  
  # 初期化
  def initialize( user )
    super( user )
    @ym = Time.new.strftime("%Y%m")
  end
  
  def setup_from_params( params )
    return unless params

    super( params )
    @base_salary = params[:base_salary]
    @grade_start = params[:grade_start]
    @grade_end = params[:grade_end]
  end
  
  def list
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_pensions(@ym, @base_salary)
  end
end
