class Bs::AssetsController < Base::HyaccController
  include Depreciation::DepreciationUtil

  view_attribute :title => '資産管理'
  view_attribute :branches, :only => :index
  before_filter :load_accounts, :only => 'index'

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
    
    if params[:commit] == '償却待に設定'
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_created?
      @asset.status = ASSET_STATUS_WAITING
    elsif params[:commit] == '償却待を解除'
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_waiting?
      @asset.status = ASSET_STATUS_CREATED
    elsif params[:commit] == '償却実行'
      raise HyaccException.new(ERR_INVALID_ACTION) unless @asset.status_waiting? or @asset.status_depreciating?
      @asset.status = ASSET_STATUS_DEPRECIATING
    end

    begin
      @asset.transaction do
        if @asset.status_created?
          @asset.depreciations.clear
        elsif @asset.status_waiting?
          @asset.depreciations = create_depreciations(@asset)
        elsif @asset.status_depreciating?
          d = @asset.depreciations.where(:fiscal_year => current_user.company.current_fiscal_year_int).first
          d.journal_headers = create_journals(d, current_user)
          d.depreciated = true
          d.save!
          if @asset.depreciations.where(:depreciated => false).empty?
            @asset.status = ASSET_STATUS_DEPRECIATED
          end
        end
        
        @asset.save!
      end

      flash[:notice] = '資産を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      @asset.status = @asset.status_was
      render 'edit'
    end
  end

  private

  def finder
    unless @finder
      @finder = AssetFinder.new(params[:finder])
      @finder.company_id = current_company.id
      @finder.fiscal_year ||= current_company.fiscal_year
      @finder.branch_id ||= current_user.employee.default_branch.id
      @finder.page = params[:page] || 1
      @finder.per_page = current_user.slips_per_page
    end
    
    @finder
  end

  def asset_params
    params.require(:asset).permit(
        :code, :name, :account_id, :branch_id, :sub_account_id, :durable_years, :ym, :day,
        :amount, :depreciation_method, :depreciation_limit, :remarks, :business_use_ratio, :lock_version)
  end

  def load_accounts
    sql = SqlBuilder.new
    sql.append('account_type = ?', ACCOUNT_TYPE_ASSET)
    sql.append('and trade_type = ?', TRADE_TYPE_EXTERNAL)
    sql.append('and journalizable = ?', true)
    sql.append('and depreciable = ?', true)
    sql.append('and deleted = ?', false)

    @accounts = Account.where(sql.to_a)
    unless @accounts.present?
      render :no_account and return
    end
    @sub_accounts = []
  end

end
