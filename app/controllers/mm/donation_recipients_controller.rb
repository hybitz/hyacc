class Mm::DonationRecipientsController < Base::HyaccController
  def index
    @donation_recipients = current_company.donation_recipients
      .order(:kind, :name)
      .paginate(page: params[:page] || 1, per_page: 10)
  end

  def new
    @donation_recipient = current_company.donation_recipients.build(kind: SUB_ACCOUNT_CODE_DONATION_DESIGNATED)
  end

  def show
    @donation_recipient = current_company.donation_recipients.find(params[:id])
  end

  def edit
    @donation_recipient = current_company.donation_recipients.find(params[:id])
  end

  def create
    @donation_recipient = current_company.donation_recipients.build(donation_recipient_params)

    begin
      @donation_recipient.transaction do
        @donation_recipient.save!
      end

      flash[:notice] = "寄付先「#{@donation_recipient.name}」を登録しました。"
      render 'common/reload'
    rescue => e
      handle(e)
      render :new
    end
  end

  def update
    @donation_recipient = current_company.donation_recipients.find(params[:id])
    params_to_assign = donation_recipient_params
    params_to_assign = params_to_assign.except(:kind) if @donation_recipient.journal_detail_donation_recipients.exists?
    @donation_recipient.attributes = params_to_assign

    begin
      @donation_recipient.transaction do
        @donation_recipient.save!
      end

      flash[:notice] = "寄付先「#{@donation_recipient.name}」を更新しました。"
      render 'common/reload'
    rescue => e
      handle(e)
      render :edit
    end
  end

  def destroy
    @donation_recipient = current_company.donation_recipients.find(params[:id])

    begin
      if @donation_recipient.journal_detail_donation_recipients.exists?
        raise HyaccException.new(ERR_DONATION_RECIPIENT_LINKED)
      end

      @donation_recipient.transaction do
        @donation_recipient.destroy_logically!
      end

      flash[:notice] = "寄付先「#{@donation_recipient.name}」を削除しました。"
    rescue => e
      handle(e)
    end

    redirect_to action: 'index'
  end

  private

  def donation_recipient_params
    permitted = [
      :kind, :name,
      :announcement_number, :purpose,
      :address, :purpose_or_name, :trust_name
    ]
    ret = params.require(:donation_recipient).permit(*permitted)
    ret = ret.merge(company_id: current_company.id) if action_name == 'create'
    ret
  end
end
