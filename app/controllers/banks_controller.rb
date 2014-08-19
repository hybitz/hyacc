class BanksController < Base::HyaccController
  view_attribute :title => '金融機関'
  view_attribute :deleted_types

  def index
    @finder = BankFinder.new(params[:finder])
    @banks = @finder.list(:per_page => current_user.slips_per_page)
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

  private

  def bank_params
    params.require(:bank).permit(:name, :code)
  end

end
