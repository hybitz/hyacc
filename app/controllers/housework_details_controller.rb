class HouseworkDetailsController < Base::HyaccController
  include JournalUtil
  
  view_attribute :title => '家事按分'
  view_attribute :accounts, :conditions => ['account_type=? and journalizable=?', ACCOUNT_TYPE_EXPENSE, true]
  view_attribute :sub_accounts

  def new
    hw = Housework.find(params[:housework_id])
    @hwd = hw.details.build
  end

  def create
    @housework = Housework.find(params[:housework_id])
    begin
      @hwd = @housework.details.build(housework_detail_params)
      @hwd.transaction do
        @hwd.save!
      end

      flash[:notice] = '家事按分を登録しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :new
    end
  end

  def edit
    @hwd = HouseworkDetail.find(params[:id])
  end
  
  def update
    @hwd = HouseworkDetail.find(params[:id])

    begin
      @hwd.transaction do
        @hwd.update_attributes!(housework_detail_params)
      end
      
      flash[:notice] = '家事按分を更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :edit
    end
  end
  
  def destroy
    @hwd = HouseworkDetail.find(params[:id])

    begin
      @hwd.transaction do
        unless @hwd.destroy
          raise HyaccException.new
        end

        @hwd.housework.journal_headers.each do |jh|
          jh.save!
        end
      end

      flash[:notice] = '家事按分を削除しました。'
    rescue => e
      handle(e)
    end

    redirect_to houseworks_path
  end

  private

  def housework_detail_params
    params.require(:housework_detail).permit(:account_id, :sub_account_id, :business_ratio)
  end

end
