class BankAccountsController < Base::HyaccController
  before_filter :check_banks
  view_attribute :title => '金融口座'
  view_attribute :banks, :except => :index
  
  def index
    @bank_accounts = BankAccount.not_deleted
  end
  
  def new
    @bank_account = BankAccount.new(:bank_id => @banks.first.id)
    setup_view_attributes
  end

  def create
    begin
      @bank_account = BankAccount.new(bank_account_params)
      @bank_account.transaction do
        @bank_account.save!
      end

      flash[:notice] = '金融口座を登録しました。'
      render 'common/reload'

    rescue Exception => e
      handle(e)
      setup_view_attributes
      render :new
    end
  end

  def edit
    @bank_account = BankAccount.find(params[:id])
    setup_view_attributes
  end
  
  def update
    @bank_account = BankAccount.find(params[:id])

    begin
      @bank_account.transaction do
        @bank_account.update_attributes!(bank_account_params)
      end
      
      flash[:notice] = '金融口座を更新しました。'
      render 'common/reload'

    rescue Exception => e
      handle(e)
      setup_view_attributes
      render :edit
    end
  end
  
  def destroy
    @bank_account = BankAccount.find(params[:id])

    begin
      @bank_account.transaction do
        @bank_account.destroy_logically!
      end
      
      flash[:notice] = '金融口座を削除しました。'
    rescue Exception => e
      handle(e)
    end
    
    redirect_to :action => :index
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(
    :code, :name, :holder_name, :bank_id, :bank_office_id, :financial_account_type)
  end

  # 銀行が未登録の場合は金融機関管理に誘導する
  def check_banks
    if Bank.count == 0
      render :template => 'common/banks_required' and return
    end
  end

  def setup_view_attributes
    @bank_offices = load_bank_offices(@bank_account.bank_id)
  end
end
