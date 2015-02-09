class BanksController < Base::HyaccController
  view_attribute :title => '金融機関'

  helper_method :finder

  def index
    @banks = finder.list
  end

  def show
    @bank = Bank.find(params[:id])
  end

  def new
    @bank = Bank.new
  end

  def edit
    @bank = Bank.find(params[:id])
  end

  def create
    @bank = Bank.new(bank_params)

    begin
      @bank.transaction do
        @bank.save!
      end

      flash[:notice] = '金融機関を登録しました。'
      render 'common/reload'
    
    rescue => e
      handle(e)
      render :new
    end
  end

  def update
    @bank = Bank.find(params[:id])

    begin
      @bank.transaction do
        @bank.update_attributes!(bank_params)
      end

      flash[:notice] = '金融機関を更新しました。'
      render 'common/reload'
      
    rescue => e
      handle(e)
      render :edit
    end
  end

  def destroy
    @bank = Bank.find(params[:id])

    begin
      @bank.transaction do
        @bank.destroy_logically!
      end

      flash[:notice] = '金融機関を削除しました。'

    rescue => e
      handle(e)
    end

    redirect_to :action => 'index'
  end

  def add_bank_office
    @bank_office = BankOffice.new
    render :partial => 'bank_office_fields', :locals => {:bank_office => @bank_office, :index => params[:index]}
  end  

  private

  def finder
    unless @finder
      @finder = BankFinder.new(params[:finder])
      @finder.page = params[:page]
      @finder.per_page = current_user.slips_per_page
    end
    
    @finder
  end

  def bank_params
    params.require(:bank).permit(:name, :code, :bank_offices_attributes => [:id, :code, :name, :disabled])
  end

end
