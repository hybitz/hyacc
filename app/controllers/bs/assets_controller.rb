class Bs::AssetsController < Base::HyaccController
  view_attribute :branches, only: :index
  before_action :preload_accounts, only: 'index'

  helper_method :finder

  def index
    @assets = finder.list
  end

  def show
    @asset = Asset.find(params[:id])
  end

  def edit
    @asset = Asset.find(params[:id])
  end

  def update
    @asset = Asset.find(params[:id])
    @asset.attributes = asset_params

    begin
      @asset.transaction do
        @asset.save!
      end

      flash[:notice] = "資産 #{@asset.name} を更新しました。"
      render 'common/reload'
    rescue => e
      handle(e)
      render 'edit'
    end
  end

  def change_status
    @asset = Asset.find(params[:id])
    @asset.lock_version = params[:lock_version]
    
    case params[:status].to_i
    when ASSET_STATUS_CREATED
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_waiting?
      @asset.status = ASSET_STATUS_CREATED
    when ASSET_STATUS_WAITING
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_created?
      @asset.status = ASSET_STATUS_WAITING
    when ASSET_STATUS_DEPRECIATING
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_waiting? or @asset.status_depreciating?
      @asset.status = ASSET_STATUS_DEPRECIATING
    end

    begin
      @asset.transaction do
        if @asset.status_created?
          @asset.depreciations.map{|d| d.mark_for_destruction }
        elsif @asset.status_waiting?
          Depreciation::DepreciationUtil.create_depreciations(@asset)
        elsif @asset.status_depreciating?
          d = @asset.depreciations.find{|d| d.fiscal_year == current_company.current_fiscal_year_int }
          raise HyaccException.new(ERR_RECORD_NOT_FOUND) unless d

          Depreciation::DepreciationUtil.make_journals(d, current_user)
          d.depreciated = true
          @asset.status = ASSET_STATUS_DEPRECIATED unless @asset.depreciations.find{|d| ! d.depreciated? }
        end
        
        @asset.save!
      end

      flash[:notice] = "資産 #{@asset.name} を更新しました。"
      render 'common/reload'
    rescue => e
      handle(e)
      @asset.status = @asset.status_in_database
      render 'show'
    end
  end

  private

  def finder
    unless @finder
      @finder = AssetFinder.new(finder_params)
      @finder.fiscal_year ||= current_company.fiscal_year
      @finder.branch_id ||= current_user.employee.default_branch.id
      @finder.page = params[:page]
      @finder.per_page = current_user.slips_per_page
    end
    
    @finder
  end

  def finder_params
    if params[:finder].present?
      params.require(:finder).permit(:fiscal_year, :branch_id, :account_id)
    else
      {}
    end
  end

  def asset_params
    params.require(:asset).permit(
        :code, :name, :account_id, :branch_id, :sub_account_id, :durable_years, :ym, :day,
        :amount, :depreciation_method, :depreciation_limit, :remarks, :business_use_ratio, :lock_version)
  end

  def preload_accounts
    @accounts = Account.where(account_type: ACCOUNT_TYPE_ASSET, trade_type: TRADE_TYPE_EXTERNAL, journalizable: true, depreciable: true, deleted: false)
    render :no_account and return unless @accounts.present?
  end

end
