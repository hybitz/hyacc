class Mm::ExemptionsController < Base::HyaccController
  helper_method :finder

  def index
    @exemptions = finder.list
  end

  def new
    # 直近のデータを初期表示
    employee_id = params[:exemption][:employee_id]
    employee_id = current_user.employee.id if employee_id.blank?
    
    @d = Exemption.where(employee_id: employee_id).order(yyyy: 'desc').order(employee_id: 'asc').first
    # new_record? = true にするためdup
    @c = @d.dup
    @c.yyyy = Date.today.year
    @d.dependent_family_members.each do |dfm|
      @c.dependent_family_members.build(dfm.attributes.except("id", "created_at", "updated_at", "exemption_id"))
    end
  end

  def create
    @c = Exemption.new(exempiton_params)
    begin
      @c.transaction do
        @c.save!
      end

      flash[:notice] = '所得税控除情報を追加しました。'
      render 'common/reload'
    rescue => e
      setup_view_attributes
      handle(e)
      render 'new'
    end
  end

  def edit
    @c = Exemption.find(params[:id])
  end

  def update
    @c = Exemption.find(params[:id])

    begin
      @c.transaction do
        @c.update!(exempiton_params)
      end

      flash[:notice] = '所得税控除情報を更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render 'edit'
    end
  end

  def destroy
    c = Exemption.find(params[:id])
    c.destroy
    flash[:notice] = '所得税控除情報を削除しました。'
    redirect_to :action => 'index'
  end
  
  def add_dependent_family_member
    @dfm = DependentFamilyMember.new
    render :partial => 'dependent_fields', :locals => {:dfm => @dfm, :index => params[:index]}
  end

  private

  def finder
    @finder ||= ExemptionFinder.new(finder_params)
    @finder.company_id = current_company.id
    @finder.page = params[:page] || 1
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit(
          :calendar_year, :employee_id
        )
    end
  end

  def exempiton_params
    permitted = [:employee_id, :yyyy, :small_scale_mutual_aid,
      :life_insurance_premium_old, :life_insurance_premium_new,
      :care_insurance_premium, :private_pension_insurance_old, :private_pension_insurance_new,
      :earthquake_insurance_premium, :social_insurance_selfpay, :special_tax_for_spouse, :spouse,
      :dependents, :disabled_persons, :basic,
      :num_of_house_loan, :max_mortgage_deduction, :date_of_start_living_1,
      :mortgage_deduction_code_1, :year_end_balance_1, :date_of_start_living_2,
      :mortgage_deduction_code_2, :year_end_balance_2,
      :previous_salary, :previous_withholding_tax, :previous_social_insurance, :remarks, :fixed_tax_deduction_amount,
      :dependent_family_members_attributes => [:id, :exemption_type, :name, :kana, :my_number, :live_in, :_destroy]
    ]

    ret = params.require(:exemption).permit(permitted)
    ret.merge!(:company_id => current_company.id)
  end

end
