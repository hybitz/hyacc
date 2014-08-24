class FiscalYearsController < Base::HyaccController
  view_attribute :title => '会計年度'

  def index
    @fiscal_years = current_user.company.fiscal_years
  end

  def new
    @fiscal_year = current_user.company.new_fiscal_year
  end

  def create
    begin
      @fiscal_year = FiscalYear.new(fiscal_year_params)
      @fiscal_year.transaction do
        @fiscal_year.save!
      end

      flash[:notice] = '会計年度を登録しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :new
    end
  end

  def edit
    @fiscal_year = FiscalYear.find(params[:id])
  end

  def update
    @fiscal_year = FiscalYear.find(params[:id])

    begin
      @fiscal_year.transaction do
        @fiscal_year.update_attributes!(fiscal_year_params)

        if @fiscal_year.is_not_closed
          # 繰越仕訳があれば削除
          jh = @fiscal_year.get_carry_forward_journal
          if jh
            unless jh.destroy
              raise HyaccException.new(ERR_DB)
            end
          end

          @fiscal_year.carry_status = CARRY_STATUS_NOT_CARRIED
          @fiscal_year.carried_at = nil
          @fiscal_year.save!
        end
      end

      flash[:notice] = '会計年度を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :edit
    end
  end

  def confirm_carry_forward
    @fy = FiscalYear.find(params[:id])
  end

  def carry_forward
    @fy = FiscalYear.find(params[:id])
    next_fy = FiscalYear.where(:company_id => @fy.company_id, :fiscal_year => @fy.fiscal_year + 1).first
    next_fy_created = false

    begin
      @fy.transaction do
        @fy.lock_version = params[:lock_version]
        @fy.carry_status = CARRY_STATUS_CARRIED
        @fy.carried_at = Time.now
        @fy.save!

        # 家事按分を実行
        if params[:journalize_housework].to_i == 1
          hw = Housework.find_by_company_id_and_fiscal_year(@fy.company_id, @fy.fiscal_year)
          param = Auto::Journal::HouseworkParam.new( hw, current_user )
          factory = Auto::AutoJournalFactory.get_instance( param )
          hw.journal_headers = factory.make_journals()
          hw.save!
        end

        # 翌期の会計年度がまだなければ作成
        unless next_fy
          next_fy_created = true
          next_fy = FiscalYear.new
          next_fy.company_id = @fy.company_id
          next_fy.fiscal_year = @fy.fiscal_year + 1
          next_fy.tax_management_type = @fy.tax_management_type
          next_fy.consumption_entry_type = @fy.consumption_entry_type
          next_fy.closing_status = CLOSING_STATUS_OPEN
          next_fy.save!
        end

        # 繰越仕訳を作成
        param = Auto::Journal::CarryForwardParam.new(@fy, current_user)
        factory = Auto::AutoJournalFactory.get_instance(param)
        jh = factory.make_journals
        jh.save! if jh
      end

      flash[:notice] = '繰越処理が完了しました。'
      flash[:notice] << "翌期（#{next_fy.fiscal_year}年度）を作成しました。" if next_fy_created
      render 'common/reload'

    rescue => e
      handle(e)
      render :confirm_carry_forward
    end
  end
  
  def edit_current_fiscal_year
    @c = Company.find(current_user.company_id)
  end
  
  def update_current_fiscal_year
    @c = Company.find(params[:company_id])

    begin
      @c.transaction do
        @c.update_attributes!(update_current_fiscal_year_params)
      end
      
      flash[:notice] = '会計年度を変更しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :edit_current_fiscal_year
    end
  end

  private

  def fiscal_year_params
    params.require(:fiscal_year).permit(
        :company_id, :fiscal_year, :closing_status,
        :tax_management_type, :carry_status, :consumption_entry_type)
  end

  def update_current_fiscal_year_params
    params.require(:c).permit(:fiscal_year, :lock_version)
  end

end
